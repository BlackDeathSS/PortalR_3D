	.assume adl=1

	.section .header.icon

	.local ___icon
___icon_jump:
	jp	__start
	.db	$02

	.global ___description
___description:
	.db	"Layer-major portal renderer prototype", 0
	.extern __start
