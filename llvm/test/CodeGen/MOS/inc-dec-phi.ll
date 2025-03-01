; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs < %s | FileCheck %s

target datalayout = "e-m:e-p:16:8-p1:8:8-i16:8-i32:8-i64:8-f32:8-f64:8-a:8-Fi8-n8"
target triple = "mos"

@s = global i8 0

define i8 @incdecphi(i8 %t, i8 %v) {
; CHECK-LABEL: incdecphi:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    tay
; CHECK-NEXT:    beq .LBB0_2
; CHECK-NEXT:  ; %bb.1: ; %select.false
; CHECK-NEXT:    inx
; CHECK-NEXT:    txa
; CHECK-NEXT:    rts
; CHECK-NEXT:  .LBB0_2: ; %entry
; CHECK-NEXT:    dex
; CHECK-NEXT:    txa
; CHECK-NEXT:    rts
entry:
  %tobool.not = icmp eq i8 %t, 0
  br i1 %tobool.not, label %select.end, label %select.false

select.false:                                     ; preds = %entry
  br label %select.end

select.end:                                       ; preds = %entry, %select.false
  %. = phi i8 [ -1, %entry ], [ 1, %select.false ]
  %sub = add i8 %., %v
  ret i8 %sub
}

define i8 @load_incdecphi(i8 %t) {
; CHECK-LABEL: load_incdecphi:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    tax
; CHECK-NEXT:    beq .LBB1_2
; CHECK-NEXT:  ; %bb.1: ; %select.false
; CHECK-NEXT:    ldx s
; CHECK-NEXT:    inx
; CHECK-NEXT:    txa
; CHECK-NEXT:    rts
; CHECK-NEXT:  .LBB1_2: ; %entry
; CHECK-NEXT:    ldx s
; CHECK-NEXT:    dex
; CHECK-NEXT:    txa
; CHECK-NEXT:    rts
entry:
  %tobool.not = icmp eq i8 %t, 0
  br i1 %tobool.not, label %select.end, label %select.false

select.false:                                     ; preds = %entry
  br label %select.end

select.end:                                       ; preds = %entry, %select.false
  %. = phi i8 [ -1, %entry ], [ 1, %select.false ]
  %0 = load i8, ptr @s
  %sub = add i8 %0, %.
  ret i8 %sub
}

define void @rmw_incdecphi(i8 %t) {
; CHECK-LABEL: rmw_incdecphi:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    tax
; CHECK-NEXT:    beq .LBB2_2
; CHECK-NEXT:  ; %bb.1: ; %select.false
; CHECK-NEXT:    inc s
; CHECK-NEXT:    rts
; CHECK-NEXT:  .LBB2_2: ; %entry
; CHECK-NEXT:    dec s
; CHECK-NEXT:    rts
entry:
  %tobool.not = icmp eq i8 %t, 0
  br i1 %tobool.not, label %select.end, label %select.false

select.false:                                     ; preds = %entry
  br label %select.end

select.end:                                       ; preds = %entry, %select.false
  %. = phi i8 [ -1, %entry ], [ 1, %select.false ]
  %0 = load i8, ptr @s
  %sub = add i8 %0, %.
  store i8 %sub, ptr @s
  ret void

}

define dso_local i16 @repro() {
; CHECK-LABEL: repro:
; CHECK:       ; %bb.0:
; CHECK-NEXT:    ldx #1
; CHECK-NEXT:    bpl .LBB3_2
; CHECK-NEXT:  ; %bb.1:
; CHECK-NEXT:    ldx #255
; CHECK-NEXT:    jmp .LBB3_3
; CHECK-NEXT:  .LBB3_2:
; CHECK-NEXT:    ldx #0
; CHECK-NEXT:  .LBB3_3:
; CHECK-NEXT:    stx __rc2
; CHECK-NEXT:    ldx #255
; CHECK-NEXT:    bmi .LBB3_5
; CHECK-NEXT:  ; %bb.4:
; CHECK-NEXT:    ldx #0
; CHECK-NEXT:  .LBB3_5:
; CHECK-NEXT:    lda 1024
; CHECK-NEXT:    sta __rc3
; CHECK-NEXT:    sec
; CHECK-NEXT:    ldy 1025
; CHECK-NEXT:    sty __rc5
; CHECK-NEXT:    sty __rc4
; CHECK-NEXT:    sta __rc6
; CHECK-NEXT:    sbc __rc4
; CHECK-NEXT:    bvc .LBB3_7
; CHECK-NEXT:  ; %bb.6:
; CHECK-NEXT:    eor #128
; CHECK-NEXT:  .LBB3_7:
; CHECK-NEXT:    cmp #0
; CHECK-NEXT:    bpl .LBB3_9
; CHECK-NEXT:  ; %bb.8:
; CHECK-NEXT:    ldx #1
; CHECK-NEXT:    sec
; CHECK-NEXT:    tya
; CHECK-NEXT:    sbc __rc3
; CHECK-NEXT:    tay
; CHECK-NEXT:    stx __rc3
; CHECK-NEXT:    jmp .LBB3_10
; CHECK-NEXT:  .LBB3_9:
; CHECK-NEXT:    ldy #255
; CHECK-NEXT:    sec
; CHECK-NEXT:    lda __rc6
; CHECK-NEXT:    sbc __rc5
; CHECK-NEXT:    sty __rc3
; CHECK-NEXT:    stx __rc2
; CHECK-NEXT:    tay
; CHECK-NEXT:  .LBB3_10:
; CHECK-NEXT:    ldx #0
; CHECK-NEXT:    stx .Lrepro_sstk ; 1-byte Folded Spill
; CHECK-NEXT:    ldx #0
; CHECK-NEXT:    stx .Lrepro_sstk+1 ; 1-byte Folded Spill
; CHECK-NEXT:    tya
; CHECK-NEXT:    bpl .LBB3_15
; CHECK-NEXT:    jmp .LBB3_13
; CHECK-NEXT:  .LBB3_11:
; CHECK-NEXT:    tax
; CHECK-NEXT:    bpl .LBB3_14
; CHECK-NEXT:  ; %bb.12:
; CHECK-NEXT:    tya
; CHECK-NEXT:    bpl .LBB3_15
; CHECK-NEXT:  .LBB3_13:
; CHECK-NEXT:    lda #255
; CHECK-NEXT:    jmp .LBB3_16
; CHECK-NEXT:  .LBB3_14:
; CHECK-NEXT:    lda .Lrepro_sstk ; 1-byte Folded Reload
; CHECK-NEXT:    clc
; CHECK-NEXT:    adc __rc3
; CHECK-NEXT:    sta .Lrepro_sstk ; 1-byte Folded Spill
; CHECK-NEXT:    lda .Lrepro_sstk+1 ; 1-byte Folded Reload
; CHECK-NEXT:    adc __rc2
; CHECK-NEXT:    sta .Lrepro_sstk+1 ; 1-byte Folded Spill
; CHECK-NEXT:    tya
; CHECK-NEXT:    bmi .LBB3_13
; CHECK-NEXT:  .LBB3_15:
; CHECK-NEXT:    lda #0
; CHECK-NEXT:  .LBB3_16:
; CHECK-NEXT:    ldx .Lrepro_sstk ; 1-byte Folded Reload
; CHECK-NEXT:    stx __rc4
; CHECK-NEXT:    cpy __rc4
; CHECK-NEXT:    ldx .Lrepro_sstk+1 ; 1-byte Folded Reload
; CHECK-NEXT:    stx __rc4
; CHECK-NEXT:    sbc __rc4
; CHECK-NEXT:    bvc .LBB3_11
; CHECK-NEXT:  ; %bb.17:
; CHECK-NEXT:    eor #128
; CHECK-NEXT:    jmp .LBB3_11
  %1 = load volatile i8, ptr inttoptr (i16 1024 to ptr), align 1024
  %2 = load volatile i8, ptr inttoptr (i16 1025 to ptr), align 1
  %3 = icmp slt i8 %1, %2
  br i1 %3, label %4, label %6

4:                                                ; preds = %0
  %5 = sub i8 %2, %1
  br label %8

6:                                                ; preds = %0
  %7 = sub i8 %1, %2
  br label %8

8:                                                ; preds = %6, %4
  %9 = phi i8 [ %5, %4 ], [ %7, %6 ]
  %10 = phi i8 [ 1, %4 ], [ -1, %6 ]
  %11 = sext i8 %9 to i16
  %12 = sext i8 %10 to i16
  br label %13

13:                                               ; preds = %17, %8
  %14 = phi i16 [ %18, %17 ], [ 0, %8 ]
  %15 = icmp sgt i16 %14, %11
  br label %16

16:                                               ; preds = %16, %13
  br i1 %15, label %16, label %17

17:                                               ; preds = %16
  %18 = add nsw i16 %14, %12
  br label %13
}
