% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bd.sim.general.R
\name{bd.sim.general}
\alias{bd.sim.general}
\title{Non-constant rate Birth-Death simulation}
\usage{
bd.sim.general(
  n0,
  lambda,
  mu,
  tMax,
  lShape = NULL,
  mShape = NULL,
  nFinal = c(0, Inf),
  nExtant = c(0, Inf),
  trueExt = FALSE
)
}
\arguments{
\item{n0}{Initial number of species. Usually 1, in which case the simulation 
will describe the full diversification of a monophyletic lineage. Note that
when \code{lambda} is less than or equal to \code{mu},  many simulations will
go extinct before speciating even once. One way of generating large sample
sizes in this case is to increase \code{n0}, which will simulate the
diversification of a paraphyletic group.}

\item{lambda}{Function to hold the speciation rate over time. It will either be
interpreted as an exponential rate, or a Weibull scale if 
\code{lShape != NULL}. Can be constant, to allow for mixing of constant and
non-constant rates. One can use constructs such as \code{ifelse()} to create
rates whose underlying model change over time (see the last examples). Note
that \code{lambda} should always be greater than or equal to zero.}

\item{mu}{Similar to above, but for the extinction rate.

Note: rates should be considered as running from \code{0} to \code{tMax}, as
the simulation runs in that direction even though the function inverts times
before returning in the end.

Note: this function is meant to be called by \code{bd.sim}, so it neither
allows for as much flexibility, nor calls \code{make.rate}. If the user wishes
to use \code{bd.sim.general} with environmental or step-function rates, they
can generate the rate with \code{make.rate} and supply it to the function.}

\item{tMax}{Ending time of simulation, in million years after the clade origin. 
Any species still living after \code{tMax} is considered extant, and any 
species that would be generated after \code{tMax} is not born.}

\item{lShape}{Shape of the age-dependency in speciation rate. This will be 
equal to the shape parameter in a Weibull distribution: when smaller than one, 
speciation rate will decrease along each species' age (negative 
age-dependency). When larger than one, speciation rate will increase along each
species's age (positive age-dependency). It may be a function of time, but 
see note below for caveats therein. Default is \code{NULL}, equivalent to 
an age-independent process. For \code{lShape != NULL} (including when equal to 
one), \code{lambda} will be considered a scale (= 1/rate), and \code{rexp.var} 
will draw a Weibull distribution instead of an exponential. This means 
Weibull(rate, 1) = Exponential(1/rate). Note that even when 
\code{lShape != NULL}, \code{lambda} may still be time-dependent.}

\item{mShape}{Similar to \code{lShape}, but for the extinction rate.

Note: Time-varying shape is within expectations for most cases, but if it is
lower than 1 and varies too much (e.g. \code{0.5 + 0.5*t}), it can be biased
for higher waiting times due to computational error. Slopes (or equivalent,
since it can be any function of time) of the order of 0.01 are advisable.
It rarely also displays small biases for abrupt variations. In both cases,
error is still quite low for the purposes of the package.

Note: Shape must be greater than 0. We arbitrarily chose 0.01 as the minimum
accepted value, so if shape is under 0.01 for any reasonable time in the 
simulation, it returns an error.}

\item{nFinal}{A \code{vector} of length \code{2}, indicating an interval of 
acceptable number of species at the end of the simulation. Default value is 
\code{c(0, Inf)}, so that any number of species (including zero, the extinction
of the whole clade) is accepted. If different from default value, the process
will run until the number of total species reaches a number in the interval
\code{nFinal}.}

\item{nExtant}{A \code{vector} of length \code{2}, indicating an interval of
acceptable number of extant species at the end of the simulation. Equal to 
\code{nFinal} in every respect except for that.

Note: The function returns \code{NA} if it runs for more than \code{100000}
iterations without fulfilling the requirements of \code{nFinal} and 
\code{nExtant}.}

\item{trueExt}{A \code{logical} indicating whether the function should return
true or truncated extinction times. When \code{TRUE}, time of extinction of 
extant species will be the true time, otherwise it will be \code{NA} if a 
species is alive at the end of the simulation.

Note: This is interesting to use to test age-dependent extinction. 
Age-dependent speciation would require all speciation times (including
the ones after extinction) to be recorded, so we do not attempt to add an
option to account for that. Since age-dependent extinction and speciation
use the same underlying process, however, if one is tested to satisfacton
the other should also be in expectations.}
}
\value{
A \code{sim} object, containing extinction times, speciation times,
parent, and status information for each species in the simulation. See 
\code{?sim}.
}
\description{
Simulates a species birth-death process with general rates for any number of
starting species. Allows for the speciation/extinction rate to be (1) a 
constant, or (2) a function of time. Allows for constraining results on the 
number of species at the end of the simulation, either total or extant. The 
function can also take an optional shape argument to generate age-dependence on
speciation and/or extinction, assuming a Weibull distribution as a model of 
age-dependence. Returns a \code{sim} object (see \code{?sim}). It may return 
true extinction times or simply information on whether species lived after the
maximum simulation time, depending on input. For constant rate simulations, see
\code{bd.sim.constant}. For a function that unites all scenarios, see 
\code{bd.sim}. \code{bd.sim} also allows for extra inputs, creating a
time-dependent only rate internally through \code{make.rate}. For similar
flexibility, use \code{make.rate} to generate the desired rate.
Please note while time runs from \code{0} to \code{tMax} in the simulation, it 
returns speciation/extinction times as \code{tMax} (origin of the group) to 
\code{0} (the "present" and end of simulation), so as to conform to other
packages in the literature.
}
\examples{

# we will showcase here some of the possible scenarios for diversification,
# touching on all the kinds of rates

###
# first, even though this is bd.sim.general, we can try constant rates

# initial number of species
n0 <- 1

# maximum simulation time
tMax <- 40

# speciation
lambda <- 0.11

# extinction
mu <- 0.08

# run the simulation
sim <- bd.sim.general(n0, lambda, mu, tMax, nFinal = c(2, Inf))

# we can plot the phylogeny to take a look
if (requireNamespace("ape", quietly = TRUE)) {
  phy <- make.phylo(sim)
  ape::plot.phylo(phy)
}

###
# we can complicate things further with a linear function as a rate

# initial number of species
n0 <- 1

# maximum simulation time
tMax <- 40

# speciation
lambda <- function(t) {
  return(0.03 + 0.005*t)
}

# extinction
mu <- 0.05

# run the simulation
sim <- bd.sim.general(n0, lambda, mu, tMax, nFinal = c(2, Inf))

# we can plot the phylogeny to take a look
if (requireNamespace("ape", quietly = TRUE)) {
  phy <- make.phylo(sim)
  ape::plot.phylo(phy)
}

###
# we can also create a step function

# initial number of species
n0 <- 1

# maximum simulation time
tMax <- 40

# speciation rate
lambda <- function(t) {
  return(0.03 + 0.005*t)
}

# vector of extinction rates
mList <- c(0.06, 0.09, 0.11)

# vector of shift times. Note mShifts could be c(40, 25, 15) for
# identical results
mShifts <- c(0, 15, 25)

# let us take a look at how make.rate will make it a step function
mu <- make.rate(mList, tMax = tMax, rateShifts = mShifts)

# and plot it
plot(seq(0, tMax, 0.1), mu(seq(0, tMax, 0.1)), type = 'l',
     main = "Extintion rate as a step function", xlab = "Time (My)",
     ylab = "Rate (species/My)")

# a different way to define the same extinction function
mu <- function(t) {
  ifelse(t < 15, 0.06,
         ifelse(t < 25, 0.09, 0.11))
}

# run the simulation
sim <- bd.sim.general(n0, lambda, mu, tMax, nFinal = c(2, Inf))
# we could instead have used q made with make.rates

# we can plot the phylogeny to take a look
if (requireNamespace("ape", quietly = TRUE)) {
  phy <- make.phylo(sim)
  ape::plot.phylo(phy)
}

###
# another feature to add is age dependency
n0 <- 1

# maximum simulation time
tMax <- 40

# speciation
lambda <- 0.1

# extinction - a Weibull scale
mu <- 10

# extinction shape
mShape <- 1

# run simulation
sim <- bd.sim.general(n0, lambda, mu, tMax, mShape = mShape, 
                      nFinal = c(2, Inf))

# we can plot the phylogeny to take a look
if (requireNamespace("ape", quietly = TRUE)) {
  phy <- make.phylo(sim)
  ape::plot.phylo(phy)
}

###
 
# initial number of species
n0 <- 1

# maximum simulation time
tMax <- 40

# speciation
lambda <- 0.15

# extinction - a Weibull scale
mu <- function(t) {
  return(8 + 0.05*t)
}

# extinction shape
mShape <- 1

# run simulation
sim <- bd.sim.general(n0, lambda, mu, tMax, mShape = mShape, 
                      nFinal = c(2, Inf))

# we can plot the phylogeny to take a look
if (requireNamespace("ape", quietly = TRUE)) {
  phy <- make.phylo(sim)
  ape::plot.phylo(phy)
}

###
# initial number of species
n0 <- 1

# maximum simulation time
tMax <- 40

# speciation
lambda <- 0.15

# extinction - a Weibull scale
mu <- 5

# extinction shape
mShape <- function(t) {
  return(8 + 0.05*t)
}

# run simulation
sim <- bd.sim.general(n0, lambda, mu, tMax, mShape = mShape, 
                      nFinal = c(2, Inf))

# we can plot the phylogeny to take a look
if (requireNamespace("ape", quietly = TRUE)) {
  phy <- make.phylo(sim)
  ape::plot.phylo(phy)
}

###
# finally, we could have environmental dependency on a rate
# initial number of species
n0 <- 1

# maximum simulation time
tMax <- 40

# temperature-dependent speciation
l_t <- function(t, temp) {
 return(0.025*exp(0.1*temp))
}

# extinction
mu <- 0.075

# get the temperature data
data(temp)

# speciation
lambda <- make.rate(l_t, tMax = tMax, envRate = temp)

# run simulation
sim <- bd.sim.general(n0, lambda, mu, tMax, nFinal = c(2, Inf))

# we can plot the phylogeny to take a look
if (requireNamespace("ape", quietly = TRUE)) {
  phy <- make.phylo(sim)
  ape::plot.phylo(phy)
}

# after presenting the possible models, we can consider how to
# create mixed models, where the dependency changes over time

###
# consider speciation that becomes environment dependent
# in the middle of the simulation

# initial number of species
n0 <- 1

# maximum simulation time
tMax <- 40

# time and temperature-dependent speciation
l_t <- function(t, temp) {
  return(
    ifelse(t < 20, 0.1 - 0.005*t,
           0.05 + 0.1*exp(0.02*temp))
  )
}

# extinction
mu <- 0.1

# get the temperature data
data(temp)

# speciation
lambda <- make.rate(l_t, tMax = tMax, envRate = temp)

# run simulation
sim <- bd.sim.general(n0, lambda, mu, tMax, nFinal = c(2, Inf))

# we can plot the phylogeny to take a look
if (requireNamespace("ape", quietly = TRUE)) {
  phy <- make.phylo(sim)
  ape::plot.phylo(phy)
}

###
# we can also change the environmental variable
# halfway into the simulation

# initial number of species
n0 <- 1

# maximum simulation time
tMax <- 40

# speciation
lambda <- 0.1

# temperature-dependent extinction
m_t1 <- function(t, temp) {
  return(0.05 + 0.1*exp(0.02*temp))
}

# get the temperature data
data(temp)

# make first function
mu1 <- make.rate(m_t1, tMax = tMax, envRate = temp) 

# co2-dependent extinction
m_t2 <- function(t, co2) {
  return(0.02 + 0.14*exp(0.01*co2))
}

# get the co2 data
data(co2)

# make second function
mu2 <- make.rate(m_t2, tMax = tMax, envRate = co2)

# final extinction function
mu <- function(t) {
  ifelse(t < 20, mu1(t), mu2(t))
}

# run simulation
sim <- bd.sim.general(n0, lambda, mu, tMax, nFinal = c(2, Inf))

# we can plot the phylogeny to take a look
if (requireNamespace("ape", quietly = TRUE)) {
  phy <- make.phylo(sim)
  ape::plot.phylo(phy)
}

# note one can also use this mu1 mu2 workflow to create a rate
# dependent on more than one environmental variable, by decoupling
# the dependence of each in a different function and putting those
# together

###
# finally, note one could create an extinction rate that turns age-dependent
# in the middle, by making shape time-dependent

# initial number of species
n0 <- 1

# maximum simulation time
tMax <- 40

# speciation
lambda <- 0.15

# extinction - a Weibull scale
mu <- function(t) {
  return(8 + 0.05*t)
}

# speciation shape
mShape <- function(t) {
  return(
    ifelse(t < 30, 1, 2)
  )
}

# run simulation
sim <- bd.sim.general(n0, lambda, mu, tMax, mShape = mShape,
                      nFinal = c(2, Inf))

# we can plot the phylogeny to take a look
if (requireNamespace("ape", quietly = TRUE)) {
  phy <- make.phylo(sim)
  ape::plot.phylo(phy)
}

###
# note nFinal has to be sensible
\dontrun{
# this would return a warning, since it is virtually impossible to get 100
# species at a process with diversification rate -0.09 starting at n0 = 1
sim <- bd.sim.general(1, lambda = 0.01, mu = 1, tMax = 100, 
                      nFinal = c(100, Inf))
}

}
\author{
Bruno do Rosario Petrucci.
}
