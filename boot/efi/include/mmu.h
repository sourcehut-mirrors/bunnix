#ifndef MMU_H
#define MMU_H

#define PT_P	1 << 0
#define PT_W	1 << 1
#define PT_U	1 << 2
#define PT_PWT	1 << 3
#define PT_PCD	1 << 4
#define PT_A	1 << 5
#define PT_D	1 << 6
#define PT_PAT	1 << 7
#define PT_G	1 << 8
#define PT_XD	1 << 63

#define PDE_P	1 << 0
#define PDE_W	1 << 1
#define PDE_U	1 << 2
#define PDE_PWT	1 << 3
#define PDE_PCD	1 << 4
#define PDE_A	1 << 5
#define PDE_D	1 << 6
#define PDE_PS	1 << 7
#define PDE_G	1 << 8
#define PDE_PAT	1 << 12
#define PDE_XD	1 << 63

void init_mmu();
void kmmap(uintptr_t virt, uintptr_t phys, uintptr_t flags);

#endif
