using PredInt
using PredInt.LsqFit
using CairoMakie

# Fake Data 
x = [0.0000, 0.2000, 0.4000, 0.6000, 0.8000, 1.0000, 1.2000, 1.4000, 1.6000, 1.8000,
    2.0000, 2.2000, 2.4000, 2.6000, 2.8000, 3.0000, 3.2000, 3.4000, 3.6000, 3.8000,
    4.0000, 4.2000, 4.4000, 4.6000, 4.8000, 5.0000]

y = [2.248357, 1.852447, 2.170077, 2.535356, 1.587211, 1.520393, 2.362862, 1.895285,
    1.217561, 1.666633, 1.108931, 1.055208, 1.358548, 0.232401, 0.279959, 0.816480,
    0.548169, 1.170358, 0.519492, 0.229181, 1.631482, 0.750533, 0.863330, 0.084664,
    0.493594, 0.791220]

# Single-term exponential fit: y = a*exp(b*x)  (equivalent to 'exp1' in MATLAB)

model(x, p) = p[1] .* exp.(p[2] .* x)

fitres = curve_fit(model, x, y, [1.0, -0.1])
a, b = fitres.param
println("Fitted parameters: a = $(round(a, digits=4)), b = $(round(b, digits=4))")

# Compute the 4 requested combinations, evaluated at the same x
_, lo11, hi11 = predint(fitres, model, x, 0.95; interval=:observation, simultaneous=false)
_, lo12, hi12 = predint(fitres, model, x, 0.95; interval=:observation, simultaneous=true)
_, lo21, hi21 = predint(fitres, model, x, 0.95; interval=:functional,  simultaneous=false)
yhat, lo22, hi22 = predint(fitres, model, x, 0.95; interval=:functional,  simultaneous=true)

# Plot with CairoMakie: 2x2 grid, one panel per combination
fig = Figure(size = (1000, 800))

function plot_panel!(fig, pos, title, lo, hi)
    ax = Axis(fig[pos...], title = title, xlabel = "x", ylabel = "y")
    band!(ax, x, lo, hi; color = (:steelblue, 0.25))
    lines!(ax, x, yhat; color = :steelblue, linewidth = 2, label = "fit")
    lines!(ax, x, lo; color = :steelblue, linestyle = :dash)
    lines!(ax, x, hi; color = :steelblue, linestyle = :dash)
    scatter!(ax, x, y; color = :black, markersize = 6, label = "data")
    axislegend(ax; position = :rt)
    return ax
end

plot_panel!(fig, (1,1), "Observation, non-simultaneous (p11)", lo11, hi11)
plot_panel!(fig, (1,2), "Observation, simultaneous (p12)",     lo12, hi12)
plot_panel!(fig, (2,1), "Functional, non-simultaneous (p21)",  lo21, hi21)
plot_panel!(fig, (2,2), "Functional, simultaneous (p22)",      lo22, hi22)

dir = joinpath(PredIntdir(), "assets", "temp", "predint_exp1.png")

save(dir, fig)

display(fig)