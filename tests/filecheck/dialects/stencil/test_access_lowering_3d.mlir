// RUN: xdsl-opt %s -t mlir -p convert-stencil-to-ll-mlir | filecheck %s

"builtin.module"() ({
    "func.func"() ({
    ^0(%0 : !stencil.field<[-1 : i32, -1 : i32, -1 : i32], f64>):
        %1 = "stencil.cast"(%0) {"lb" = #stencil.index<[-4 : i64, -4 : i64, -4 : i64]>, "ub" = #stencil.index<[68 : i64, 70 : i64, 72 : i64]>} : (!stencil.field<[-1 : i64, -1 : i64, -1 : i64], f64>) -> !stencil.field<[72 : i64, 74 : i64, 76 : i64], f64>
        %2 = "stencil.load"(%1) {"lb" = #stencil.index<[-4 : i64, -4 : i64, -4 : i64]>, "ub" = #stencil.index<[68 : i64, 70 : i64, 72 : i64]>} : (!stencil.field<[72 : i64, 74 : i64, 76 : i64], f64>) -> !stencil.temp<[72 : i64, 74 : i64, 76 : i64], f64>
        "stencil.apply"(%2) ({
        ^b0(%3: !stencil.temp<[72 : i64, 74 : i64, 76 : i64], f64>):
            %4 = "stencil.access"(%3) {"offset" = #stencil.index<[-1 : i64, 0 : i64, 1 : i64]>} : (!stencil.temp<[72 : i64, 74 : i64, 76 : i64], f64>) -> f64
        }) {"lb" = #stencil.index<[0 : i64, 0 : i64, 0 : i64]>, "ub" = #stencil.index<[64 : i64, 64 : i64, 68 : i64]>} : (!stencil.temp<[72 : i64, 74 : i64, 76 : i64], f64>) -> ()
        "func.return"() : () -> ()
    }) {"sym_name" = "test_funcop_lowering", "function_type" = (!stencil.field<[-1 : i32, -1 : i32, -1 : i32], f64>) -> (), "sym_visibility" = "private"} : () -> ()
}) : () -> ()

// CHECK-NEXT: "builtin.module"() ({
// CHECK-NEXT:   "func.func"() ({
// CHECK-NEXT:   ^0(%0 : memref<?x?x?xf64>):
// CHECK-NEXT:     %1 = "memref.cast"(%0) : (memref<?x?x?xf64>) -> memref<76x74x72xf64>
// CHECK-NEXT:     %2 = "arith.constant"() {"value" = 0 : index} : () -> index
// CHECK-NEXT:     %3 = "arith.constant"() {"value" = 1 : index} : () -> index
// CHECK-NEXT:     %4 = "arith.constant"() {"value" = 64 : index} : () -> index
// CHECK-NEXT:     %5 = "arith.constant"() {"value" = 64 : index} : () -> index
// CHECK-NEXT:     %6 = "arith.constant"() {"value" = 68 : index} : () -> index
// CHECK-NEXT:     "scf.parallel"(%2, %2, %2, %4, %5, %6, %3, %3, %3) ({
// CHECK-NEXT:     ^1(%7 : index, %8 : index, %9 : index):
// CHECK-NEXT:       %10 = "arith.constant"() {"value" = 5 : index} : () -> index
// CHECK-NEXT:       %11 = "arith.constant"() {"value" = 4 : index} : () -> index
// CHECK-NEXT:       %12 = "arith.constant"() {"value" = 3 : index} : () -> index
// CHECK-NEXT:       %13 = "arith.addi"(%9, %10) : (index, index) -> index
// CHECK-NEXT:       %14 = "arith.addi"(%8, %11) : (index, index) -> index
// CHECK-NEXT:       %15 = "arith.addi"(%7, %12) : (index, index) -> index
// CHECK-NEXT:       %16 = "memref.load"(%1, %13, %14, %15) : (memref<76x74x72xf64>, index, index, index) -> f64
// CHECK-NEXT:       "scf.yield"() : () -> ()
// CHECK-NEXT:     }) {"operand_segment_sizes" = array<i32: 3, 3, 3, 0>} : (index, index, index, index, index, index, index, index, index) -> ()
// CHECK-NEXT:     "func.return"() : () -> ()
// CHECK-NEXT:   }) {"sym_name" = "test_funcop_lowering", "function_type" = (memref<?x?x?xf64>) -> (), "sym_visibility" = "private"} : () -> ()
// CHECK-NEXT: }) : () -> ()