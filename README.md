# paleobuddy

`paleobuddy` is an R package to simulate species diversification and generate fossil records and phylogenies. While the literature on species birth-death simulators is extensive, including important software like [paleotree](https://github.com/dwbapst/paleotree) and [APE](https://github.com/cran/ape), we concluded there were interesting gaps to be filled regarding possible diversification scenarios. Differently from most simulators in the field, we strived for flexibility over focus, implementing and planning to implement a large array of regimens for users to experiment with and combine. In this way, `paleobuddy` can be used in complement to other simulators as a flexible jack of all trades, or, in the case of scenarios implemented only here, can allow for robust and easy simulations for novel situations.

## Important functions

`BDSim` is the main birth-death simulator of `PaleoBuddy`, allowing for multiple arguments to build a large number of possible scenarios. One can choose any type of time-varying constant for speciation `pp` and extinction `qq`. On top of the base rates, we allow for a `shape` parameter for each, if one chooses to interpret `pp` and `qq` as scales of a Weibull distribution for age-dependent diversification. We take the novel step of including time-varying scale for the Weibull distribution as an option for the rates. While time-varying shape is implemented, it has not been thoroughly tested as of the writing of this, and so we do not recommend its use unless the user tests it themselves. One can also supply an `env` parameter to make rates dependent on an environmental variable such as temperature. Finally, one could supply rates as a numeric vector, and supply a corresponding `shifts` with the respective shift times. These can all be combined as the user wishes, creating a myriad of possible scenarios we believe will allow for unprecedented flexibility in a researcher's simulation tools.

`SampleClade` is a fossil record-generating function, returning an organized data frame with occurrence times - or occurrence time ranges, provided the user supplies the respective interval vector. It allows for a sampling rate `rr` that can be similarly flexible to `pp` and `qq` above, with the exception of a `shape` parameter, since we ommitted that option given the absence of the use of Weibull distributions to model age-dependent sampling in the literature. Instead, we allow for the user to supply a function they wish to use as age-dependent sampling, `pFUN`, such as the PERT distribution used in [PyRate](https://github.com/dsilvestro/PyRate). If possible, the user can supply a maximizer for that function, `pFUNMax`, which would lead to faster computation. In the case of sampling, age-dependency and time-varying sampling rates are incompatible, at least as of the initial publication of the package. Still, `SampleClade` allows for unprecedented flexibility in sampling, letting the user combine as they wish time-varying, and environmentally-dependent functions, and any maximizable age-dependent function as a sampling rate.

`PB2phylo` closes the trio of most important functions of the package, taking a PB simulation and returning a `phylo` object from the APE package (see above).

Besides its main species diversification-simulating functions, `PaleoBuddy` also supplies the user with a few interesting statistical tools, such as `rexp_var`, a generalization of the `rexp` function in BaseR that allows for time-varying exponential rates and a `shape` parameter, in which case it generalizes the `rweibull` function.

## Authors

`PaleoBuddy` was idealized by Bruno do Rosario Petrucci and Tiago Bosisio Quental. The birth-death, statistical and part of the sampling functions were written by Bruno. Most of the sampling functions were written by Matheus Januário Sousa. 
