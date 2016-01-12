main:
    sei
    lda #$7f
    sta $912e       ; Disable and acknowledge interrupts.
    sta $912d
    sta $911e       ; Disable restore key NMIs.

stop:
    ldy #@(- cinfo_patch_end cinfo_patch 1)
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
n:  dec counter
    bne -l
    dec @(++ counter)
    bne -l
    rts

loaded_tramp:
    org $1f00

tramp:
    ldy #@(- cinfo_game_end cinfo_game 1)
    jsr copy_forwards
    jsr $2002
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
n:  dec counter
    bne -l
    dec @(++ counter)
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
    <patch_size @(++ >patch_size)
cinfo_patch_end:
cinfo_end:

cinfo_game:
    <loaded_game >loaded_game
    $00 $10
    <game_size @(++ >game_size)
cinfo_game_end:

loaded_game:
    @(fetch-file "obj/game.8k.crunched.prg")

loaded_patch:
    "XXXXXXXXX"
    @(fetch-file "obj/free+8k.crunched.pal.prg")
