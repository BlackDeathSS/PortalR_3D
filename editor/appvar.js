"use strict";

(function exposeAppVarTools(root) {
  const SIGNATURE = [42, 42, 84, 73, 56, 51, 70, 42, 26, 10, 0];
  const FILE_HEADER_SIZE = 55;
  const ENTRY_PREFIX_SIZE = 19;
  const APPVAR_TYPE = 0x15;
  const APPVAR_NAME = "DOOMLVL1";

  function writeAscii(target, offset, text, length) {
    for (let index = 0; index < length; index++) {
      target[offset + index] = index < text.length ? text.charCodeAt(index) & 0x7f : 0;
    }
  }

  function checksum(bytes, offset, length) {
    let value = 0;
    for (let index = 0; index < length; index++) value = (value + bytes[offset + index]) & 0xffff;
    return value;
  }

  function pack(rawBuffer, name = APPVAR_NAME) {
    const raw = new Uint8Array(rawBuffer);
    if (raw.byteLength > 65533) throw new Error("AppVar data exceeds 65,533 bytes.");
    if (!/^[A-Z][A-Z0-9]{0,7}$/.test(name)) throw new Error("Invalid calculator AppVar name.");

    const storedLength = raw.byteLength + 2;
    const sectionLength = raw.byteLength + ENTRY_PREFIX_SIZE;
    const output = new Uint8Array(FILE_HEADER_SIZE + sectionLength + 2);
    const view = new DataView(output.buffer);
    let at = 0;

    output.set(SIGNATURE, at); at += SIGNATURE.length;
    writeAscii(output, at, "Doom CE Level Workshop", 42); at += 42;
    view.setUint16(at, sectionLength, true); at += 2;

    view.setUint16(at, 13, true); at += 2;
    view.setUint16(at, storedLength, true); at += 2;
    output[at++] = APPVAR_TYPE;
    writeAscii(output, at, name, 8); at += 8;
    output[at++] = 0;
    output[at++] = 0x80;
    view.setUint16(at, storedLength, true); at += 2;
    view.setUint16(at, raw.byteLength, true); at += 2;
    output.set(raw, at); at += raw.byteLength;

    view.setUint16(at, checksum(output, FILE_HEADER_SIZE, sectionLength), true);
    return output.buffer;
  }

  function unpack(appVarBuffer, expectedName = APPVAR_NAME) {
    const bytes = new Uint8Array(appVarBuffer);
    const view = new DataView(appVarBuffer);
    if (bytes.byteLength < FILE_HEADER_SIZE + ENTRY_PREFIX_SIZE + 2 ||
        SIGNATURE.some((value, index) => bytes[index] !== value)) {
      throw new Error("Not a TI-83/84 variable file.");
    }

    const sectionLength = view.getUint16(53, true);
    const sectionOffset = FILE_HEADER_SIZE;
    const checksumOffset = sectionOffset + sectionLength;
    if (checksumOffset + 2 !== bytes.byteLength) throw new Error("Invalid variable section length.");
    if (view.getUint16(sectionOffset, true) !== 13) throw new Error("Unsupported variable header.");
    if (bytes[sectionOffset + 4] !== APPVAR_TYPE) throw new Error("The TI file is not an AppVar.");

    let name = "";
    for (let index = 0; index < 8 && bytes[sectionOffset + 5 + index]; index++) {
      name += String.fromCharCode(bytes[sectionOffset + 5 + index]);
    }
    if (expectedName && name !== expectedName) {
      throw new Error(`Expected ${expectedName}, found ${name || "an unnamed AppVar"}.`);
    }

    const storedLength = view.getUint16(sectionOffset + 2, true);
    const repeatedLength = view.getUint16(sectionOffset + 15, true);
    const rawLength = view.getUint16(sectionOffset + 17, true);
    if (storedLength !== repeatedLength || storedLength !== rawLength + 2 ||
        rawLength + ENTRY_PREFIX_SIZE !== sectionLength) {
      throw new Error("Invalid AppVar payload lengths.");
    }
    const expectedChecksum = view.getUint16(checksumOffset, true);
    const actualChecksum = checksum(bytes, sectionOffset, sectionLength);
    if (expectedChecksum !== actualChecksum) throw new Error("AppVar checksum mismatch.");

    return appVarBuffer.slice(sectionOffset + ENTRY_PREFIX_SIZE, checksumOffset);
  }

  root.DoomCeAppVar = Object.freeze({ APPVAR_NAME, pack, unpack });
})(globalThis);
