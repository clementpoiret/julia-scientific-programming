using DelimitedFiles
using Dates
using Plots

wikiEVDraw = DelimitedFiles.readdlm("./assets/wikipediaEVDraw.csv", ',')

col1 = wikiEVDraw[:, 1]

for i = 1:length(col1)
    col1[i] = Dates.DateTime(col1[i], "d u y")
end

dayssincefirst(x) = Dates.datetime2rata(x) - Dates.datetime2rata(last(col1))
epidays = Array{Int64}(undef, length(col1))
for i = 1:length(col1)
    epidays[i] = dayssincefirst(col1[i])
end

wikiEVDraw[:, 1] = epidays
DelimitedFiles.writedlm("./assets/wikipediaEVDdatesconverted.csv", wikiEVDraw, ',')

tvalsfromdata = wikiEVDraw[:, 1]
allcases = wikiEVDraw[:, 2]

gr()
plot(epidays, allcases,
title="West African EVD epidemic, total cases",
xlabel="Days since 22 March 2014",
ylabel="Total cases to date (three countries)",
marker=(:circle, 3),
line=(:path, "gray"),
legend=false,
grid=false)

savefig("./assets/WAfricanEVD.png")


rows, cols = size(wikiEVDraw)
for j = 1:cols
    for i = 1:rows
        if !isdigit(string(wikiEVDraw[i, j])[1])
            wikiEVDraw[i, j] = 0
        end
    end
end

EVDcasesbycountry = wikiEVDraw[:, [4, 6, 8]]
plot(epidays, EVDcasesbycountry,
marker=(3),
label=["Guinea" "Liberia" "Sierra Leone"],
title="EVD in West Africa, epidemic segregated by country",
xlabel="Days since 22 March 2014",
ylabel="Number of cases to date",
line=(:scatter),
legend=:topleft)

savefig("./assets/WAfricanEVDsegregated.png")

function updateSIR(popnvector)
    susceptibles = popnvector[1];
    infecteds = popnvector[2];
    removeds = popnvector[3];
    newS = susceptibles - λ*susceptibles*infecteds*dt
    newI = infecteds + λ*susceptibles*infecteds*dt - γ*infecteds*dt
    newR = removeds + γ*infecteds*dt
    return [newS newI newR]
end

λ = 1.47e-6; # Threshold S* = 0.1S(0); S* = gamma/lambda => lambda = 0.05/2.2 * 10^6
γ = 0.125; # based on a 20-day infectious period per patient (1/gamma)
dt = .5;
tfinal = 610;
s0 = 1.0e5; # Populations of Guinea, Liberia and Sierra Leone
i0 = 20.;
r0 = 0.;

nsteps = round(Int64, tfinal/dt);
resultvals = Array{Float64}(undef, nsteps+1, 3);
timevec = Array{Float64}(undef, nsteps+1);
resultvals[1,:] = [s0, i0, r0];
timevec[1] = 0.;

for step = 1:nsteps
    resultvals[step+1, :] = updateSIR(resultvals[step, :])
    timevec[step+1] = timevec[step] + dt
end

svals = resultvals[:,1];
ivals = resultvals[:,2];
rvals = resultvals[:,3];
cvals = ivals + rvals

plot(timevec, cvals,
label = "Model values",
xlabel = "Epidemic day",
ylabel = "Number of cases to date",
title = "Model versus data")

plot!(tvalsfromdata, allcases,
legend = :right,
line = :scatter,
label = "Reported number of cases")

savefig("./assets/modelvsdata.png")