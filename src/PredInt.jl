module PredInt

using LsqFit
using LinearAlgebra
using Distributions
using ForwardDiff

export LsqFit
export param_gradient
export predint
export PredIntdir


function PredIntdir()
    pkgdir(@__MODULE__)
end

"""
Jacobian of model(x, p) wrt p, evaluated at arbitrary x
"""
function param_gradient(model, x0, p)
    return ForwardDiff.gradient(pp -> model(x0, pp), p)
end

"""
    predint(fit, model, xnew, level=0.95; interval=:observation, simultaneous=false)

Returns a matrix with columns [fit_value, lower, upper] for each x in xnew,
mirroring MATLAB's predint output (fitresult evaluated + bounds).
"""
function predint(fitres, model, xnew, level::Real=0.95; interval::Symbol=:observation, simultaneous::Bool=false)

    p   = fitres.param
    k   = length(p)
    n   = length(fitres.resid)
    dof = n - k
    s2  = sum(fitres.resid .^ 2) / dof

    XtXinv = inv(fitres.jacobian' * fitres.jacobian)
    alpha  = 1 - level

    crit = if simultaneous
        sqrt(k * quantile(FDist(k, dof), level))     # Working-Hotelling/Scheffé-type band
    else
        quantile(TDist(dof), 1 - alpha/2)             # pointwise t-critical value
    end

    n_new = length(xnew)
    yhat  = Vector{Float64}(undef, n_new)
    lower = Vector{Float64}(undef, n_new)
    upper = Vector{Float64}(undef, n_new)

    for (i, x0) in enumerate(xnew)
        yh = model(x0, p)
        g0 = param_gradient(model, x0, p)
        var_mean  = s2 * (g0' * XtXinv * g0)
        var_total = interval == :observation ? var_mean + s2 : var_mean
        se = sqrt(var_total)

        yhat[i]  = yh
        lower[i] = yh - crit*se
        upper[i] = yh + crit*se
    end

    return yhat, lower, upper
end
end
