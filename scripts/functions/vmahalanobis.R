### Calculate Mahalanobis distance for formants
vmahalanobis = function(dat) {
  if (nrow(dat) < 25) {
    dat$zF1F2 = NA
    return(dat)
  }
  means = c(mean(dat$sF1_mean, na.rm = T), mean(dat$sF2_mean, na.rm = T))
  cov = cov(cbind(dat$sF1_mean, dat$sF2_mean))

  dat$zF1F2 = mahalanobis(
    cbind(dat$sF1_mean, dat$sF2_mean),
    center = means,
    cov = cov
  )
  dat
}
