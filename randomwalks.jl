### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 84086dd0-cee2-11eb-0054-6daab703dc7f
begin
    import Pkg
    Pkg.activate(mktempdir())
    Pkg.add([
        Pkg.PackageSpec(name="Plots"),
        Pkg.PackageSpec(name="PlutoUI"),
        Pkg.PackageSpec(name="Distributions"),
		Pkg.PackageSpec(name="StatsPlots"),

    ])
    using Plots, PlutoUI, Distributions, StatsPlots
end

# ╔═╡ 01c84816-938d-48f9-bd98-367cdb539baa
begin
	# Initialize the arrays with zeros
	x = zeros(100)
	y = zeros(100)
	
	# Initialize the starting position.
	x[1] = 5.0
	y[1] = 5.0

	# Loop over the walk and add the random noise.
	for ii=2:length(x)
		newx = x[ii-1]
		newy = y[ii-1]
		while true
			dx = rand(Normal())*0.5
			dy = rand(Normal())*0.5
			newx = x[ii-1] + dx
			newy = y[ii-1] + dy
			if (0<=newx<=10.0) && (0<=newy<=10.0)
				x[ii] = newx
				y[ii] = newy
				break
			end
		end
		
	end
end

# ╔═╡ 6ec0c117-9867-4669-9758-3795884f8d73
begin
	anim = @animate for i ∈ 1:length(x)
    	scatter([x[i]],[y[i]],
			xlims=(0,10),
			ylims=(0,10),
			legend=false,
			framestyle=:box)
	end

	gif(anim, "anim_fps15.gif", fps = 15)
end

# ╔═╡ d91a7845-dfc1-4daf-99d7-d4d16596d48c
begin
	N = 100
	p = 10000
	# Initialize the arrays with zeros
	xx = zeros(p,N)
	yy = zeros(p,N)
	
	for jj=1:N
		
		# Initialize the starting position.
		xx[1,jj] = rand(Uniform(0, 10))
		yy[1,jj] = rand(Uniform(0, 10))

		# Loop over the walk and add the random noise.
		for ii=2:p
			newx = xx[ii-1,jj]
			newy = yy[ii-1,jj]
			while true
				dx = rand(Normal())*0.1
				dy = rand(Normal())*0.1
				newx = xx[ii-1,jj] + dx
				newy = yy[ii-1,jj] + dy
				if (0<=newx<=10.0) && (0<=newy<=10.0)
					xx[ii,jj] = newx
					yy[ii,jj] = newy
					break
				end
			end

		end
	end
end

# ╔═╡ 1f0cdab6-e09f-482a-9447-6932ab87f5d1
begin
	diffusion = 0.5
	NF = 10
	ff = zeros(p,N)
	fF = zeros(p,NF)
	fF[1,:] .= 100   # foragers have food = 100
	intDist = 0.3 # distance at which interactions are initiated
	
	# Initialize the arrays with zeros
	xxF = zeros(p,NF)
	yyF = zeros(p,NF)
	
	for jj=1:NF
		
		# Initialize the starting position.
		xxF[1,jj] = 0
		yyF[1,jj] = 0

		# Loop over the walk and add the random noise.
		for ii=2:p
			newx = xxF[ii-1,jj]
			newy = yyF[ii-1,jj]
			while true
				dx = rand(Normal())*diffusion
				dy = rand(Normal())*diffusion
				newx = xxF[ii-1,jj] + dx
				newy = yyF[ii-1,jj] + dy
				if (0<=newx<=10.0) && (0<=newy<=10.0)
					xxF[ii,jj] = newx
					yyF[ii,jj] = newy
					fF[ii,jj] = fF[ii-1,jj]
					for j=1:N
						ff[ii,j] = ff[ii-1,j]
						dist = sqrt((xxF[ii-1,jj]-xx[ii-1,j])^2+(yyF[ii-1,jj]-yy[ii-1,j])^2)
						if dist<intDist
							tofill = 100-ff[ii-1,j]
							if tofill <=0
								continue
							end
							transfer = rand(Exponential(tofill*.2))
							println(transfer)
							if transfer>tofill
								transfer = tofill
							end
							if transfer>=fF[ii-1,jj]
								fF[ii,jj]=100
								#xxF[ii,jj]=0
								#yyF[ii,jj]=0
								ff[ii,j] = ff[ii-1,j] + fF[ii-1,jj]
							else
								fF[ii,jj] = fF[ii-1,jj] - transfer
								ff[ii,j] = ff[ii-1,j] + transfer
							end
						end
					end
					break
				end
			end

		end
	end
end

# ╔═╡ 2ecfb056-2486-4dc1-be45-825b38975066
xx[1,:]

# ╔═╡ 83151cec-2b31-41ca-a718-89a599494698
begin
	anim3 = @animate for i ∈ 1:p
    	scatter([xx[i,:]],[yy[i,:]],
			xlims=(0,10),
			ylims=(0,10),
			legend = false,
			framestyle=:box,
			color=:red)
		
			scatter!([xxF[i,:]],[yyF[i,:]],
			xlims=(0,10),
			ylims=(0,10),
			legend = false,
			framestyle=:box,
			color=:blue)

	end

	gif(anim3, "anim_fps15_3.gif", fps = 15)
end

# ╔═╡ fcb59fa7-8eb9-41a7-b794-134598abb560
plot(ff[1:1000,10])


# ╔═╡ c1c07da4-cdbd-4c78-88bb-81ea965f9e37
begin
	ff_avg = sum(ff,dims=2)/100
	plot(ff_avg)
end

# ╔═╡ fdfb1502-e071-4d89-8439-4f5130544edc
histogram(ff[8000,:],bins=20)


# ╔═╡ Cell order:
# ╠═84086dd0-cee2-11eb-0054-6daab703dc7f
# ╠═01c84816-938d-48f9-bd98-367cdb539baa
# ╠═6ec0c117-9867-4669-9758-3795884f8d73
# ╠═d91a7845-dfc1-4daf-99d7-d4d16596d48c
# ╠═1f0cdab6-e09f-482a-9447-6932ab87f5d1
# ╠═2ecfb056-2486-4dc1-be45-825b38975066
# ╠═83151cec-2b31-41ca-a718-89a599494698
# ╠═fcb59fa7-8eb9-41a7-b794-134598abb560
# ╠═c1c07da4-cdbd-4c78-88bb-81ea965f9e37
# ╠═fdfb1502-e071-4d89-8439-4f5130544edc
