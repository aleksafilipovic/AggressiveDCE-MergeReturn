; ModuleID = 'Tests/test.cpp'
source_filename = "Tests/test.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str.1 = private unnamed_addr constant [17 x i8] c"max(3,7)   = %d\0A\00", align 1
@.str.2 = private unnamed_addr constant [17 x i8] c"sign(-5)   = %d\0A\00", align 1
@.str.3 = private unnamed_addr constant [17 x i8] c"sign(0)    = %d\0A\00", align 1
@.str.4 = private unnamed_addr constant [20 x i8] c"classify(200) = %d\0A\00", align 1
@__const.main.arr = private unnamed_addr constant [5 x i32] [i32 10, i32 20, i32 30, i32 40, i32 50], align 16
@.str.5 = private unnamed_addr constant [21 x i8] c"find 30 at index %d\0A\00", align 1
@.str.6 = private unnamed_addr constant [21 x i8] c"find 99 at index %d\0A\00", align 1

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local noundef i32 @_Z3maxii(i32 noundef %a, i32 noundef %b) #0 {
entry:
  %retval = alloca i32, align 4
  %a.addr = alloca i32, align 4
  %b.addr = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  store i32 %b, ptr %b.addr, align 4
  %0 = load i32, ptr %a.addr, align 4
  %1 = load i32, ptr %b.addr, align 4
  %cmp = icmp sgt i32 %0, %1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %2 = load i32, ptr %a.addr, align 4
  store i32 %2, ptr %retval, align 4
  br label %return

if.end:                                           ; preds = %entry
  %3 = load i32, ptr %b.addr, align 4
  store i32 %3, ptr %retval, align 4
  br label %return

return:                                           ; preds = %if.end, %if.then
  %4 = load i32, ptr %retval, align 4
  ret i32 %4
}

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local noundef i32 @_Z4signi(i32 noundef %x) #0 {
entry:
  %retval = alloca i32, align 4
  %x.addr = alloca i32, align 4
  store i32 %x, ptr %x.addr, align 4
  %0 = load i32, ptr %x.addr, align 4
  %cmp = icmp sgt i32 %0, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 1, ptr %retval, align 4
  br label %return

if.end:                                           ; preds = %entry
  %1 = load i32, ptr %x.addr, align 4
  %cmp1 = icmp slt i32 %1, 0
  br i1 %cmp1, label %if.then2, label %if.end3

if.then2:                                         ; preds = %if.end
  store i32 -1, ptr %retval, align 4
  br label %return

if.end3:                                          ; preds = %if.end
  store i32 0, ptr %retval, align 4
  br label %return

return:                                           ; preds = %if.end3, %if.then2, %if.then
  %2 = load i32, ptr %retval, align 4
  ret i32 %2
}

; Function Attrs: mustprogress noinline uwtable
define dso_local void @_Z17print_if_positivei(i32 noundef %x) #1 {
entry:
  %x.addr = alloca i32, align 4
  store i32 %x, ptr %x.addr, align 4
  %0 = load i32, ptr %x.addr, align 4
  %cmp = icmp sle i32 %0, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %return

if.end:                                           ; preds = %entry
  %1 = load i32, ptr %x.addr, align 4
  %call = call i32 (ptr, ...) @printf(ptr noundef @.str, i32 noundef %1)
  br label %return

return:                                           ; preds = %if.end, %if.then
  ret void
}

declare i32 @printf(ptr noundef, ...) #2

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local noundef i32 @_Z8classifyi(i32 noundef %x) #0 {
entry:
  %retval = alloca i32, align 4
  %x.addr = alloca i32, align 4
  store i32 %x, ptr %x.addr, align 4
  %0 = load i32, ptr %x.addr, align 4
  %cmp = icmp slt i32 %0, 0
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %1 = load i32, ptr %x.addr, align 4
  %cmp1 = icmp slt i32 %1, -100
  br i1 %cmp1, label %if.then2, label %if.end

if.then2:                                         ; preds = %if.then
  store i32 -2, ptr %retval, align 4
  br label %return

if.end:                                           ; preds = %if.then
  store i32 -1, ptr %retval, align 4
  br label %return

if.else:                                          ; preds = %entry
  %2 = load i32, ptr %x.addr, align 4
  %cmp3 = icmp sgt i32 %2, 100
  br i1 %cmp3, label %if.then4, label %if.end5

if.then4:                                         ; preds = %if.else
  store i32 2, ptr %retval, align 4
  br label %return

if.end5:                                          ; preds = %if.else
  store i32 1, ptr %retval, align 4
  br label %return

return:                                           ; preds = %if.end5, %if.then4, %if.end, %if.then2
  %3 = load i32, ptr %retval, align 4
  ret i32 %3
}

; Function Attrs: mustprogress noinline nounwind uwtable
define dso_local noundef i32 @_Z10find_firstPiii(ptr noundef %arr, i32 noundef %len, i32 noundef %val) #0 {
entry:
  %retval = alloca i32, align 4
  %arr.addr = alloca ptr, align 8
  %len.addr = alloca i32, align 4
  %val.addr = alloca i32, align 4
  %i = alloca i32, align 4
  store ptr %arr, ptr %arr.addr, align 8
  store i32 %len, ptr %len.addr, align 4
  store i32 %val, ptr %val.addr, align 4
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, ptr %i, align 4
  %1 = load i32, ptr %len.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %2 = load ptr, ptr %arr.addr, align 8
  %3 = load i32, ptr %i, align 4
  %idxprom = sext i32 %3 to i64
  %arrayidx = getelementptr inbounds i32, ptr %2, i64 %idxprom
  %4 = load i32, ptr %arrayidx, align 4
  %5 = load i32, ptr %val.addr, align 4
  %cmp1 = icmp eq i32 %4, %5
  br i1 %cmp1, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  %6 = load i32, ptr %i, align 4
  store i32 %6, ptr %retval, align 4
  br label %return

if.end:                                           ; preds = %for.body
  br label %for.inc

for.inc:                                          ; preds = %if.end
  %7 = load i32, ptr %i, align 4
  %inc = add nsw i32 %7, 1
  store i32 %inc, ptr %i, align 4
  br label %for.cond, !llvm.loop !6

for.end:                                          ; preds = %for.cond
  store i32 -1, ptr %retval, align 4
  br label %return

return:                                           ; preds = %for.end, %if.then
  %8 = load i32, ptr %retval, align 4
  ret i32 %8
}

; Function Attrs: mustprogress noinline norecurse uwtable
define dso_local noundef i32 @main() #3 {
entry:
  %retval = alloca i32, align 4
  %arr = alloca [5 x i32], align 16
  store i32 0, ptr %retval, align 4
  %call = call noundef i32 @_Z3maxii(i32 noundef 3, i32 noundef 7)
  %call1 = call i32 (ptr, ...) @printf(ptr noundef @.str.1, i32 noundef %call)
  %call2 = call noundef i32 @_Z4signi(i32 noundef -5)
  %call3 = call i32 (ptr, ...) @printf(ptr noundef @.str.2, i32 noundef %call2)
  %call4 = call noundef i32 @_Z4signi(i32 noundef 0)
  %call5 = call i32 (ptr, ...) @printf(ptr noundef @.str.3, i32 noundef %call4)
  %call6 = call noundef i32 @_Z8classifyi(i32 noundef 200)
  %call7 = call i32 (ptr, ...) @printf(ptr noundef @.str.4, i32 noundef %call6)
  call void @_Z17print_if_positivei(i32 noundef 42)
  call void @_Z17print_if_positivei(i32 noundef -1)
  call void @llvm.memcpy.p0.p0.i64(ptr align 16 %arr, ptr align 16 @__const.main.arr, i64 20, i1 false)
  %arraydecay = getelementptr inbounds [5 x i32], ptr %arr, i64 0, i64 0
  %call8 = call noundef i32 @_Z10find_firstPiii(ptr noundef %arraydecay, i32 noundef 5, i32 noundef 30)
  %call9 = call i32 (ptr, ...) @printf(ptr noundef @.str.5, i32 noundef %call8)
  %arraydecay10 = getelementptr inbounds [5 x i32], ptr %arr, i64 0, i64 0
  %call11 = call noundef i32 @_Z10find_firstPiii(ptr noundef %arraydecay10, i32 noundef 5, i32 noundef 99)
  %call12 = call i32 (ptr, ...) @printf(ptr noundef @.str.6, i32 noundef %call11)
  ret i32 0
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #4

attributes #0 = { mustprogress noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress noinline uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress noinline norecurse uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 21.1.8 (6ubuntu1)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
