; simple.ll
; Multiple ret instructions per function (no printf, no string constants)

target triple = "x86_64-unknown-linux-gnu"

; f: int, 3 ret sites
define i32 @f(i32 %x) {
entry:
  %cmp1 = icmp sgt i32 %x, 10
  br i1 %cmp1, label %gt10, label %check_neg

gt10:
  ret i32 1

check_neg:
  %cmp2 = icmp slt i32 %x, 0
  br i1 %cmp2, label %neg, label %zero_case

neg:
  ret i32 -1

zero_case:
  ret i32 0
}

; g: float, 3 ret sites
define float @g(float %y) {
entry:
  %cmp1 = fcmp ogt float %y, 1.0
  br i1 %cmp1, label %gt1, label %check_neg

gt1:
  ret float 2.0

check_neg:
  %cmp2 = fcmp olt float %y, 0.0
  br i1 %cmp2, label %neg, label %mid

neg:
  ret float -1.0

mid:
  ret float 0.5
}

; h: void, 3 ret sites
define void @h(i32 %n) {
entry:
  %cmp1 = icmp sgt i32 %n, 0
  br i1 %cmp1, label %pos, label %check_neg

pos:
  ret void

check_neg:
  %cmp2 = icmp slt i32 %n, 0
  br i1 %cmp2, label %neg, label %zero_case

neg:
  ret void

zero_case:
  ret void
}

; main
define i32 @main() {
entry:
  %r1 = call i32 @f(i32 15)
  %r2 = call float @g(float 2.5)
  call void @h(i32 5)
  call void @h(i32 -3)
  call void @h(i32 0)

  ret i32 0
}
