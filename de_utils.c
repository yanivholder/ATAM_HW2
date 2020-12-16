#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
//# <STUDENT FILL>
	// TODO: if we omit inline assembly:  store_idt(&tmpidtr);
	asm volatile( "sidt %0" : "=m"(*idtr) );
// </STUDENT FILL>
}

void my_load_idt(struct desc_ptr *idtr) {
// <STUDENT FILL>
	// if we omit inline assembly: load_idt(addr);
	asm volatile( "lidt %0" : : "m"(*idtr) );
// <STUDENT FILL>
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
// <STUDENT FILL>
	// TODO: pack_gate(gate, GATE_INTERRUPT, addr, 0, 0, __KERNEL_CS);
	gate->offset_low	= (u16) addr;
	gate->offset_middle	= (u16) (addr >> 16);
	gate->offset_high	= (u32) (addr >> 32);
// </STUDENT FILL>
}

unsigned long my_get_gate_offset(gate_desc *gate) {
// <STUDENT FILL>
	// TODO: return gate_offset(gate);
#ifdef CONFIG_X86_64
	return gate->offset_low | ((unsigned long)gate->offset_middle << 16) |
		((unsigned long) gate->offset_high << 32);
#else
	return gate->offset_low | ((unsigned long)gate->offset_middle << 16);
#endif
// </STUDENT FILL>
}
