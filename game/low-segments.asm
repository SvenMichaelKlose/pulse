stackmem_size = 48

start_of_relocated:

stackmem:
    org $180
    @(segment :size stackmem_size)

lowmem = @(+ stackmem stackmem_size)

    org $200
if @(not *tape-release?*)
    @(segment :size #x200)
end if
if @*tape-release?*
    @(segment :size #x118)
    0 0 ; NMI vector
    @(segment :size (- #x400 #x31a))
end if

; Fill up to $1400
fill @(- realstart start_of_relocated stackmem_size #x200)
org realstart
