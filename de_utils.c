#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
//# <STUDENT FILL>
	// TODO: if we omit inline assembly:  store_idt(&tmpidtr);
	__asm__ __volatile__ ("SIDT %%rax;"
						 :
						 :"a"(idtr)
						 :"%rax"
						 );
// </STUDENT FILL>
}

void my_load_idt(struct desc_ptr *idtr) {
// <STUDENT FILL>
	// if we omit inline assembly: load_idt(addr);
	__asm__ __volatile__ ("LIDT %%rax;"
						 :
						 :"a"(idtr)
						 :"%rax"
						 );
// <STUDENT FILL>
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
// <STUDENT FILL>
	// TODO: pack_gate(gate, GATE_INTERRUPT, addr, 0, 0, __KERNEL_CS);
	pack_gate(gate, GATE_INTERRUPT, addr, 0, 0, __KERNEL_CS);
// </STUDENT FILL>
}

unsigned long my_get_gate_offset(gate_desc *gate) {
// <STUDENT FILL>
	// TODO: return gate_offset(gate);
	return gate_offset(gate);
// </STUDENT FILL>
}
