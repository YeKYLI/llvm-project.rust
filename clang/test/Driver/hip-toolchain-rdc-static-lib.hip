// RUN: %clang -### --target=x86_64-linux-gnu \
// RUN:   -x hip --cuda-gpu-arch=gfx803 --cuda-gpu-arch=gfx900 \
// RUN:   --no-offload-new-driver --emit-static-lib -nogpulib \
// RUN:   -fuse-ld=lld -B%S/Inputs/lld -fgpu-rdc -nogpuinc \
// RUN:   %S/Inputs/hip_multiple_inputs/a.cu \
// RUN:   %S/Inputs/hip_multiple_inputs/b.hip \
// RUN: 2>&1 | FileCheck %s

// emit objects for host side path
// CHECK: [[CLANG:".*clang.*"]] "-cc1" "-triple" "x86_64-unknown-linux-gnu"
// CHECK-SAME: "-aux-triple" "amdgcn-amd-amdhsa"
// CHECK-SAME: "-emit-obj"
// CHECK-SAME: {{.*}} "-main-file-name" "a.cu"
// CHECK-SAME: "-fgpu-rdc"
// CHECK-SAME: {{.*}} "-o" [[A_OBJ_HOST:".*o"]] "-x" "hip"
// CHECK-SAME: {{.*}} [[A_SRC:".*a.cu"]]

// CHECK: [[CLANG]] "-cc1" "-triple" "x86_64-unknown-linux-gnu"
// CHECK-SAME: "-aux-triple" "amdgcn-amd-amdhsa"
// CHECK-SAME: "-emit-obj"
// CHECK-SAME: {{.*}} "-main-file-name" "b.hip"
// CHECK-SAME: "-fgpu-rdc"
// CHECK-SAME: {{.*}} "-o" [[B_OBJ_HOST:".*o"]] "-x" "hip"
// CHECK-SAME: {{.*}} [[B_SRC:".*b.hip"]]

// generate image for device side path on gfx803
// CHECK: [[CLANG]] "-cc1" "-triple" "amdgcn-amd-amdhsa"
// CHECK-SAME: "-aux-triple" "x86_64-unknown-linux-gnu"
// CHECK-SAME: "-emit-llvm-bc"
// CHECK-SAME: {{.*}} "-main-file-name" "a.cu"
// CHECK-SAME: "-fcuda-is-device"
// CHECK-SAME: "-target-cpu" "gfx803"
// CHECK-SAME: "-fgpu-rdc"
// CHECK-SAME: {{.*}} "-o" [[A_BC1:".*bc"]] "-x" "hip"
// CHECK-SAME: {{.*}} [[A_SRC]]

// CHECK: [[CLANG]] "-cc1" "-triple" "amdgcn-amd-amdhsa"
// CHECK-SAME: "-aux-triple" "x86_64-unknown-linux-gnu"
// CHECK-SAME: "-emit-llvm-bc"
// CHECK-SAME: {{.*}} "-main-file-name" "b.hip"
// CHECK-SAME: "-fcuda-is-device"
// CHECK-SAME: "-target-cpu" "gfx803"
// CHECK-SAME: "-fgpu-rdc"
// CHECK-SAME: {{.*}} "-o" [[B_BC1:".*bc"]] "-x" "hip"
// CHECK-SAME: {{.*}} [[B_SRC]]

// CHECK-NOT: "*.llvm-link"
// CHECK-NOT: ".*opt"
// CHECK-NOT: ".*llc"
// CHECK: [[LLD: ".*lld.*"]] {{.*}} "-plugin-opt=-amdgpu-internalize-symbols"
// CHECK-SAME: "--lto-partitions={{[0-9]+}}"
// CHECK-SAME: "-plugin-opt=mcpu=gfx803"
// CHECK-SAME: "-o" "[[IMG_DEV1:.*out]]" [[A_BC1]] [[B_BC1]]

// generate image for device side path on gfx900
// CHECK: [[CLANG]] "-cc1" "-triple" "amdgcn-amd-amdhsa"
// CHECK-SAME: "-aux-triple" "x86_64-unknown-linux-gnu"
// CHECK-SAME: "-emit-llvm-bc"
// CHECK-SAME: {{.*}} "-main-file-name" "a.cu"
// CHECK-SAME: "-fcuda-is-device"
// CHECK-SAME: "-target-cpu" "gfx900"
// CHECK-SAME: "-fgpu-rdc"
// CHECK-SAME: {{.*}} "-o" [[A_BC2:".*bc"]] "-x" "hip"
// CHECK-SAME: {{.*}} [[A_SRC]]

// CHECK: [[CLANG]] "-cc1" "-triple" "amdgcn-amd-amdhsa"
// CHECK-SAME: "-aux-triple" "x86_64-unknown-linux-gnu"
// CHECK-SAME: "-emit-llvm-bc"
// CHECK-SAME: {{.*}} "-main-file-name" "b.hip"
// CHECK-SAME: "-fcuda-is-device"
// CHECK-SAME: "-target-cpu" "gfx900"
// CHECK-SAME: "-fgpu-rdc"
// CHECK-SAME: {{.*}} "-o" [[B_BC2:".*bc"]] "-x" "hip"
// CHECK-SAME: {{.*}} [[B_SRC]]

// CHECK-NOT: "*.llvm-link"
// CHECK-NOT: ".*opt"
// CHECK-NOT: ".*llc"
// CHECK: [[LLD]] {{.*}} "-plugin-opt=-amdgpu-internalize-symbols"
// CHECK-SAME: "--lto-partitions={{[0-9]+}}"
// CHECK-SAME: "-plugin-opt=mcpu=gfx900"
// CHECK-SAME: "--whole-archive"
// CHECK-SAME: "-o" "[[IMG_DEV2:.*out]]" [[A_BC2]] [[B_BC2]]
// CHECK-SAME: "--no-whole-archive"

// combine images generated into hip fat binary object
// CHECK: [[BUNDLER:".*clang-offload-bundler"]] "-type=o"
// CHECK-SAME: "-targets={{.*}},hipv4-amdgcn-amd-amdhsa--gfx803,hipv4-amdgcn-amd-amdhsa--gfx900"
// CHECK-SAME: "-input=[[IMG_DEV1]]" "-input=[[IMG_DEV2]]" "-output=[[BUNDLE:.*hipfb]]"

// CHECK: [[MC:".*clang.*"]] "-o" [[OBJBUNDLE:".*o"]] "{{.*}}.mcin"

// CHECK: [[AR:".*llvm-ar.*"]] "rcsD" "{{.*}}.out" [[A_OBJ_HOST]] [[B_OBJ_HOST]] [[OBJBUNDLE]]
