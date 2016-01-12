s = 0
d = 2
c = 4

main:
    sei
    lda #$7f
    sta $912e       ; Disable and acknowledge interrupts.
    sta $912d
    sta $911e       ; Disable restore key NMIs.

l:  lsr $9004
    bne -l
    lda #0
    sta $9002
    sta $900f

    ldy #@(- cinfo_patch_end cinfo 1)
    jsr copy_backwards

    ldx #0
l:  lda loaded_tramp,x
    sta tramp,x
    dex
    bne -l
    jmp tramp

copy_cinfo:
    ldx #@(- cinfo_end cinfo 1)
l:  lda cinfo,y
    sta s,x
    dex
    dey
    bne -l
    rts

copy_backwards:
    jsr copy_cinfo
    ldy #0
l:  lda (s),y
    sta (d),y
    dec s
    lda s
    cmp #$ff
    bne +n
    dec @(++ s)
n:  dec d
    lda d
    cmp #$ff
    bne +n
    dec @(++ d)
n:  dec c
    lda c
    cmp #$ff
    bne -l
    dec @(++ c)
    lda @(++ c)
    cmp #$ff
    bne -l
    rts

loaded_tramp:
    org $1f00

tramp:
    ldy #@(- cinfo_game_end cinfo 1)
    jsr copy_forwards
    lda #vic_unexpanded
    sta model
;    jsr $2002
    lda #@(+ 128 22)
    sta $9002
    jmp $1002

copy_forwards:
    jsr copy_cinfo
    ldy #0
l:  lda (s),y
    sta (d),y
    inc s
    bne +n
    inc @(++ s)
n:  inc d
    bne +n
    inc @(++ d)
n:  dec c
    lda c
    cmp #$ff
    bne -l
    dec @(++ c)
    lda @(++ c)
    cmp #$ff
    bne -l
    rts
tramp_end:

    org @(+ loaded_tramp (- tramp_end tramp))

game_size = @(length (fetch-file "obj/game.8k.crunched.prg"))
patch_size = @(length (fetch-file "obj/free+8k.crunched.pal.prg"))
loaded_patch_end = @(+ loaded_patch (-- patch_size))
patch_end = @(+ #x2000 (-- patch_size))

cinfo:
cinfo_patch:
    <loaded_patch_end >loaded_patch_end
    <patch_end >patch_end
    <patch_size >patch_size
cinfo_patch_end:
cinfo_end:

cinfo_game:
    <loaded_game >loaded_game
    $00 $10
    <game_size >game_size
cinfo_game_end:

loaded_game:
    @(fetch-file "obj/game.8k.crunched.prg")

loaded_patch:
    @(fetch-file "obj/free+8k.crunched.pal.prg")
