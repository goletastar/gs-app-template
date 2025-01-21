#include <limits.h>
#include "turbo.h"
#include "gtest/gtest.h"

namespace {

TEST(AddTest, HandlesSmallInts) {
  ASSERT_EQ(Add(1,3), 4);
}

}  // namespace
