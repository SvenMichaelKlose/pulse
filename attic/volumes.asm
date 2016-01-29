    fill @(- 256 (low *pc*))

volumes:
    @(apply #'+ (maptimes [let x _
                            (maptimes [/ (* _ x) 16] 16)]
                          16))
