using Plots

r = 5
x0, y0 = 1, 2

function trialcircle(r, x0, y0)
    t = range(0, stop=2π, length=200)
    x, y = r*cos.(t), r*sin.(t)
    x, y = x.+x0, y.+y0
    plot(x, y)
end

function trialcircle!(r, x0, y0)
    t = range(0, stop=2π, length=200)
    x, y = r*cos.(t), r*sin.(t)
    x, y = x.+x0, y.+y0
    plot!(x, y)
end

trialcircle(0,0,0)
for r = .1:.1:4
    trialcircle!(r, r, 0)
end
plot!(grid=false, legend=false, aspect_ratio=1)

