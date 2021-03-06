% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sample.species.R
\name{sample.species}
\alias{sample.species}
\title{Constant and time-dependent rate species sampling}
\usage{
sample.species(sim, rho, tMax, S)
}
\arguments{
\item{sim}{A \code{sim} object, containing extinction times, speciation times,
parent, and status information for each species in the simulation. See 
\code{?sim}.}

\item{rho}{Sampling rate (per species per million years) over time. It can be
a \code{numeric} describing a constant rate or a \code{function(t)} describing
the variation in sampling over time. For more flexibility on sampling, see
\code{make.rate} for creating more complex rates. Note that \code{rho} should
always be greater than or equal to zero.}

\item{tMax}{The maximum simulation time, used by \code{rexp.var}. A sampling
time greater than \code{tMax} would mean the occurrence is sampled after the
present, so for consistency we require this argument. This is also required
to ensure time follows the correct direction both in the Poisson process and
in the return.}

\item{S}{The species number to be sampled. Since \code{sample.species} will be 
called by a wrapper using \code{lapply}, it is through \code{S} that we apply
this function.}
}
\value{
A vector of occurrence times for that species.
}
\description{
Generates a vector of occurrence times for a species in a simulation using a
a Poisson process. Allows for the Poisson rate to be (1) a constant or (2) a 
function of time. For sampling of more than one species and/or taking into 
account species age in addition to absolute time, see \code{sample.clade} and
\code{sample.general}. \code{sample.clade} also allows for more flexibility
options, see \code{make.rate}.
Note that while the Poisson process occurs in forward time, we return (both in
birth-death functions and here) results in backwards time, so that time is
inverted using \code{tMax} both at the beginning and end of 
\code{sample.species}.
}
\examples{

###
# let us start with a linear increase in preservation rate

# simulate a group
sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)

# in case first simulation was short-lived
while ((sim$TS[1] - ifelse(is.na(sim$TE[1]), 0, sim$TE[1])) < 10) {
  sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)
}

# we will need to get exact durations for some examples, so
sim$TE[sim$EXTANT] <- 0
# this is necessary since the default is to have NA for extant species

# preservation function
rho <- function(t) {
  return(1 + 0.25*t)
}

# time
time <-  seq(0, 10, by = 0.1)

# visualizing from the past to the present
plot(x = time, y = rev(rho(time)), main="Simulated preservation", type = "l",
     xlab = "Mya", ylab = "preservation rate",
     xlim = c(10, sim$TE[1]))

# sample
occs <- sample.species(sim = sim, rho = rho, tMax = 10, S = 1)

# check histogram
hist(occs,
     xlim = c(10, sim$TE[1]),
     xlab = "Mya")
lines(time, rev(rho(time)))

###
# now let us try a step function

# simulate a group
sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)

# in case first simulation was short lived
while ((sim$TS[1] - ifelse(is.na(sim$TE[1]), 0, sim$TE[1])) < 10) {
  sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)
}

# we will need to get exact durations for some examples, so
sim$TE[sim$EXTANT] <- 0
# this is necessary since the default is to have NA for extant species

# we can create the sampling rate here from a few vectors

# rates
rList <-  c(1, 3, 2)

# rate shift times -  this could be c(10, 6, 2)
# and would produce the same function
rShifts <- c(0, 4, 8)

# create the rate to visualize it
rho <- make.rate(rList, tMax = 10, rateShifts = rShifts)

# time
time <-  seq(0, 10, by = 0.1)

# visualizing the plot from past to present
plot(x = time, y = rev(rho(time)), main = "Simulated preservation", type = "l",
     xlab = "Mya", ylab = "preservation rate",
     xlim = c(10, sim$TE[1]))

# sample
occs <- sample.species(sim = sim, rho = rho, tMax = 10, S = 1)

# check histogram
hist(occs,
     xlim = c(10, sim$TE[1]),
     xlab = "Mya")

# frontiers of each regime
abline(v = 10 - rShifts, col = "red")

###
# we can create a step function in a different way as well

# simulate a group
sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)

# in case first simulation was short-lived
while ((sim$TS[1] - ifelse(is.na(sim$TE[1]), 0, sim$TE[1])) < 10) {
  sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)
}

# we will need to get exact durations for some examples, so
sim$TE[sim$EXTANT] <- 0
# this is necessary since the default is to have NA for extant species

# preservation function
rho <- function(t) {
  ifelse(t < 4, 1,
         ifelse(t < 8, 3, 0.5))
}
# note how this function should be exactly the same as the previous one

# time
time <-  seq(0, 10, by = 0.1)

# visualizing the plot from past to present
plot(x = time, y = rev(rho(time)), main = "Simulated preservation", type = "l",
     xlab = "Mya", ylab = "preservation rate",
     xlim = c(10, sim$TE[1]))

# sample
occs <- sample.species(sim = sim, rho = rho, tMax = 10, S = 1)

# check histogram
hist(occs,
     xlim = c(10, sim$TE[1]),
     xlab = "Mya")
abline(v = 10 - rShifts, col = "red")

###
# finally we could generate sampling dependent on temperature

# simulate a group
sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)

# in case first simulation was short-lived
while ((sim$TS[1] - ifelse(is.na(sim$TE[1]), 0, sim$TE[1])) < 10) {
  sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)
}

# we will need to get exact durations for some examples, so
sim$TE[sim$EXTANT] <- 0
# this is necessary since the default is to have NA for extant species

# preservation function dependent on temperature
r_t <-  function(t, temp) {
  return(0.25*temp)
}

# get the temperature data
data(temp)

# final preservation
rho <- make.rate(r_t, tMax = tMax, envRate = temp)

# visualizing the plot from past to present
plot(x = time, y = rev(rho(time)), main = "Simulated preservation", type = "l",
     xlab = "Mya", ylab = "preservation rate",
     xlim = c(10, ifelse(is.na(sim$TE[1]), 0, sim$TE[1])))

# sample
occs <- sample.species(sim = sim, rho = rho, tMax = 10, S = 1)

# check histogram
hist(occs,
     xlim = c(10, ifelse(is.na(sim$TE[1]), 0, sim$TE[1])),
     xlab = "Mya")
lines(time, rev(rho(time)))

# after presenting the possible models, we can consider how to
# create mixed models, where the dependency changes over time

###
# consider sampling that becomes environment dependent
# in the middle of the simulation

# simulate a group
sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)

# in case first simulation was short-lived
while ((sim$TS[1] - ifelse(is.na(sim$TE[1]), 0, sim$TE[1])) < 10) {
  sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)
}

# we will need to get exact durations for some examples, so
sim$TE[sim$EXTANT] <- 0
# this is necessary since the default is to have NA for extant species

# preservation function dependent on t and temperature
r_t <-  function(t, temp) {
  return(
    ifelse(t < 5, 5 - 0.5*t,
           0.5*temp)
  )
}

# get the temperature data
data(temp)

# final preservation
rho <- make.rate(r_t, tMax = tMax, envRate = temp)

# visualizing the plot from past to present
plot(x = time, y = rev(rho(time)), main = "Simulated preservation", type = "l",
     xlab = "Mya", ylab = "preservation rate",
     xlim = c(10, ifelse(is.na(sim$TE[1]), 0, sim$TE[1])))

# sample
occs <- sample.species(sim = sim, rho = rho, tMax = 10, S = 1)

# check histogram
hist(occs,
     xlim = c(10, ifelse(is.na(sim$TE[1]), 0, sim$TE[1])),
     xlab = "Mya")
lines(time, rev(rho(time)))

###
# we can also change the environmental variable
# halfway into the simulation

# simulate a group
sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)

# in case first simulation was short-lived
while ((sim$TS[1] - ifelse(is.na(sim$TE[1]), 0, sim$TE[1])) < 10) {
  sim <- bd.sim(n0 = 1, lambda = 0.1, mu = 0.1, tMax = 10)
}

# we will need to get exact durations for some examples, so
sim$TE[sim$EXTANT] <- 0
# this is necessary since the default is to have NA for extant species

# temperature-dependent preservation
r_t1 <- function(t, temp) {
  return(1 + 0.5*temp)
}

# get the temperature data
data(temp)

# make first function
rho1 <- make.rate(r_t1, tMax = tMax, envRate = temp)

# co2-dependent preservation
r_t2 <- function(t, co2) {
  return(10 - 0.1*co2)
}

# get the co2 data
data(co2)

# make second function
rho2 <- make.rate(r_t2, tMax = tMax, envRate = co2)

# final preservation function
rho <- function(t) {
  ifelse(t < 5, rho1(t), rho2(t))
}

# visualizing the plot from past to present
plot(x = time, y = rev(rho(time)), main = "Simulated preservation", type = "l",
     xlab = "Mya", ylab = "preservation rate",
     xlim = c(10, ifelse(is.na(sim$TE[1]), 0, sim$TE[1])))

# sample
occs <- sample.species(sim = sim, rho = rho, tMax = 10, S = 1)

# check histogram
hist(occs,
     xlim = c(10, ifelse(is.na(sim$TE[1]), 0, sim$TE[1])),
     xlab = "Mya")
lines(time, rev(rho(time)))

# note one can also use this rho1 rho2 workflow to create a rate
# dependent on more than one environmental variable, by decoupling
# the dependence of each in a different function and putting those
# together

}
\author{
Bruno do Rosario Petrucci and Matheus Januario.
}
