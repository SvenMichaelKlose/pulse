radio_timer = @(/ (cpu-cycles *tv*) (half (radio-rate *tv*)))

    org $1000
    $02 $10

load_8k:
    ldx #5
l:  lda loader_cfg_8k,x
    sta tape_ptr,x
    dex
    bpl -l
    jsr radio_start
    jmp flight

init_8k:
    ; Set patch vector called by game.
    lda model
    lsr
    beq +n
    jsr $2002
n:

    ; Load +16K block.
    ldx #5
l:  lda loader_cfg_16k,x
    sta tape_ptr,x
    dex
    bpl -l
    jsr radio_start
    jmp flight

init_16k:
    ; Load +24K block.
    ldx #5
l:  lda loader_cfg_24k,x
    sta tape_ptr,x
    dex
    bpl -l
    jsr radio_start
    jmp flight

init_24k:
    ; Load +32K block.
    ldx #5
l:  lda loader_cfg_32k,x
    sta tape_ptr,x
    dex
    bpl -l
    jsr radio_start
    jmp flight

init_32k:
    ; Blank screen.
    lda #0
    sta $9002

    ; Load splash screen.
    ldx #5
l:  lda loader_cfg_splash,x
    sta tape_ptr,x
    dex
    bpl -l
    jmp tape_loader_start


flight:

    ; Set timer for sample output synchronisation.
    lda #<radio_timer
    sta $9114
    lda #>radio_timer
    sta $9115
    lda #$40
    sta $911b

    ; Init sample playing and halt until first buffer
    ; has been loaded.
    lda #0
    sta rr_sample
    sta do_play_radio
l:  lda do_play_radio
    beq -l

    ldx #0
    lda #white
l:  sta colors,x
    sta @(+ 256 colors),y
    dex
    bne -l

    lda #<zoomtabs
    sta current_zoom
    lda #>zoomtabs
    sta @(++ current_zoom)
a:  lda #0
    sta scrx
    sta scry

l:  jsr draw_zoomed_line
    inc scry
    lda scry
    cmp #5
    bne -l
    inc @(+ 1 mod_src)
    jmp -a

play_sample:
    lda $911d
    asl
    bpl +done
    stx save_x
    ldx rr_sample
mod_sample_getter:
    lda sample_buffer,x
    sta $900e
    dex
    stx rr_sample
    lda #>radio_timer
    sta $9115
    lda #$40
    sta $911d
    ldx save_x
done:
    rts


draw_zoomed_line:
    lda current_zoom
    sta @(++ mod_zoom)
    lda @(++ current_zoom)
    sta @(+ 2 mod_zoom)
    jsr scrcoladdr  ; Get screen address of line.
    bmi +s          ; Over left side of the screen…
mod_zoom:
l:  ldx zoomtabs    ; Get index into pixel.
    bmi +done       ; All pixels done.
    cpy #23         ; Over right side of the screen?
    bcs +done       ; Yes, done.
mod_src:
    lda $ff00,x     ; Get pixel.
;    beq +c          ; Clear…
n:  sta (scr),y     ; Set pixel.
    inc @(++ mod_zoom) ; Step to next pixel index.
    iny             ; Step to next pixel on screen.
    jsr play_sample
    jmp -l

s:  inc @(++ mod_zoom) ; Step to next pixel index.
    iny             ; Step to next pixel on screen.
    bmi -s          ; Still over the left side.
    jmp -l          ; Start drawing.

c:  lda (scr),y
    sta mod_clrtab
mod_clrtab:
    lda clrtab
    jmp -n

done:
    rts

scrlines_l: @(maptimes [low (+ #x1e00 (* 22 _))] 23)
scrlines_h: @(maptimes [high (+ #x1e00 (* 22 _))] 23)
collines_l: @(maptimes [low (+ #x9600 (* 22 _))] 23)
collines_h: @(maptimes [high (+ #x9600 (* 22 _))] 23)

zoomtabs:
    @(apply #'+ (maptimes [alet (- 22 _)
                            (+ (maptimes [integer (* _ (/ 22 !))] !)
                               (list 255))]
                          22))

clrtab:

patch_8k_size = @(length (fetch-file (+ "obj/8k.crunched." (downcase (symbol-name *tv*)) ".prg")))
patch_16k_size = patch_8k_size
patch_24k_size = patch_8k_size
patch_32k_size = patch_8k_size
splash_size = @(length (fetch-file (+ "obj/splash.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_8k:
    $00 $20
    <patch_8k_size @(++ >patch_8k_size)
    <init_8k >init_8k

loader_cfg_16k:
    $00 $40
    <patch_16k_size @(++ >patch_16k_size)
    <init_16k >init_16k

loader_cfg_24k:
    $00 $60
    <patch_24k_size @(++ >patch_24k_size)
    <init_24k >init_24k

loader_cfg_32k:
    $00 $a0
    <patch_32k_size @(++ >patch_32k_size)
    <init_32k >init_32k

loader_cfg_splash:
    $00 $10
    <splash_size @(++ >splash_size)
    $02 $10
