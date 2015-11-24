stackmem_size = 28
lowmem_size_l = $118
lowmem_size_h = @(- #x400 #x31a) ; TODO also assign in pass 0

start_of_relocated:

stackmem:
    org $180
    segment 28

lowmem = @(+ stackmem stackmem_size)

    org $200
if @(not *tape-release?*)
    segment $200
end if
if @*tape-release?*
    segment $118
    0 0 ; NMI vector
    segment @(- #x400 #x31a)
end if

; Fill up to $1400
fill @(- realstart start_of_relocated stackmem_size lowmem_size_l (? *tape-release?* 2 0) lowmem_size_h)
org realstart
