/**
 * Copyright (c) 2024, Jayden Grubb <contact@jaydengrubb.com>
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <gtest/gtest.h>
#include <kstd/types.h>

TEST(kstd_types, sizeof) {
	EXPECT_EQ(sizeof(u8), 1);
	EXPECT_EQ(sizeof(u16), 2);
	EXPECT_EQ(sizeof(u32), 4);
	EXPECT_EQ(sizeof(u64), 8);
	EXPECT_EQ(sizeof(usize), 8);
	EXPECT_EQ(sizeof(uptr), 8);
	EXPECT_EQ(sizeof(umax), 8);
	EXPECT_EQ(sizeof(i8), 1);
	EXPECT_EQ(sizeof(i16), 2);
	EXPECT_EQ(sizeof(i32), 4);
	EXPECT_EQ(sizeof(i64), 8);
	EXPECT_EQ(sizeof(isize), 8);
	EXPECT_EQ(sizeof(iptr), 8);
	EXPECT_EQ(sizeof(imax), 8);
}

TEST(kstd_types, literals) {
	EXPECT_EQ(1KiB, 1024ULL);
	EXPECT_EQ(1MiB, 1048576ULL);
	EXPECT_EQ(1GiB, 1073741824ULL);
	EXPECT_EQ(1TiB, 1099511627776ULL);
	EXPECT_EQ(1PiB, 1125899906842624ULL);
	EXPECT_EQ(1KB, 1000ULL);
	EXPECT_EQ(1MB, 1000000ULL);
	EXPECT_EQ(1GB, 1000000000ULL);
	EXPECT_EQ(1TB, 1000000000000ULL);
	EXPECT_EQ(1PB, 1000000000000000ULL);
}
