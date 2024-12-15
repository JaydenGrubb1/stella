/**
 * Copyright (c) 2024, Jayden Grubb <contact@jaydengrubb.com>
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

extern "C" void kmain() {
	while (true) {
		asm volatile("hlt");
	}
}
