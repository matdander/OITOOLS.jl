function setup_dft(uv, nx, pixsize)
scale_rad = pixsize * (pi / 180.0) / 3600000.0;
nuv = size(uv,2)
dft = zeros(Complex{Float64}, nuv, nx*nx);
xvals = -2 * pi * scale_rad * ([(mod(i-1,nx)+1) for i=1:nx*nx] - (nx+1)/2);
yvals=  -2 * pi * scale_rad * ([(div(i-1,nx)+1) for i=1:nx*nx] - (nx+1)/2);
for uu=1:nuv
    dft[uu,:] = cis.( (uv[1,uu] * xvals + uv[2,uu] * yvals));
end
return dft
end

using NFFT
FFTW.set_num_threads(8);
function setup_nfft(uv, nx, pixsize)
  scale_rad = pixsize * (pi / 180.0) / 3600000.0;
  nfft_plan = NFFTPlan(uv*scale_rad, (nx,nx), 4, 2.0);
  return nfft_plan
end

function mod360(x)
  mod.(mod.(x+180,360.)+360., 360.) - 180.
end

function cvis_to_v2(cvis, indx)
  v2_model = abs2.(cvis[indx]);
end

function cvis_to_t3(cvis, indx1, indx2, indx3)
  t3 = cvis[indx1].*cvis[indx2].*cvis[indx3];
  t3amp = abs.(t3);
  t3phi = angle.(t3)*180./pi;
  return t3, t3amp, t3phi
end


function image_to_cvis_dft(x, dft)
  cvis_model = Array{Complex{Float64}}(size(dft, 1));
  cvis_model = dft * vec(x) / sum(x);
end

function image_to_cvis_nfft(x, nfft_plan)
  flux = sum(x)
  if (ndims(x) == 1)
    nx = Int64(sqrt(length(x)))
    cvis_model = nfft(nfft_plan, reshape(x,(nx,nx)) + 0. * im) / flux;
  else
    cvis_model = nfft(nfft_plan, x + 0. * im) / flux;
  end
end

function chi2(x, dft, data, verbose = true)
  cvis_model = image_to_cvis_dft(x, dft);
  # compute observables from all cvis
  v2_model = cvis_to_v2(cvis_model, data.indx_v2);
  t3_model, t3amp_model, t3phi_model = cvis_to_t3(cvis_model, data.indx_t3_1, data.indx_t3_2 ,data.indx_t3_3);
  chi2_v2 = sum( ((v2_model - data.v2)./data.v2_err).^2);
  chi2_t3amp = sum( ((t3amp_model - data.t3amp)./data.t3amp_err).^2);
  chi2_t3phi = sum( (mod360(t3phi_model - data.t3phi)./data.t3phi_err).^2);
  if verbose == true
    flux = sum(x);
    println("Chi2  -  Total: ", chi2_v2 + chi2_t3amp + chi2_t3phi, " V2: ", chi2_v2, " T3A: ", chi2_t3amp, " T3P: ", chi2_t3phi," Flux: ", flux)
    println("Chi2r -  Total:", (chi2_v2 + chi2_t3amp + chi2_t3phi)/(data.nv2+ data.nt3amp+ data.nt3phi), " V2: ", chi2_v2/data.nv2, " T3A: ", chi2_t3amp/data.nt3amp, " T3P: ", chi2_t3phi/data.nt3phi," Flux: ", flux)
  end
  return chi2_v2 + chi2_t3amp + chi2_t3phi
end


function chi2_fg(x, g, dft, data ) # criterion function plus its gradient w/r x
  cvis_model = image_to_cvis_dft(x, dft);
  v2_model = cvis_to_v2(cvis_model, data.indx_v2);
  t3_model, t3amp_model, t3phi_model = cvis_to_t3(cvis_model, data.indx_t3_1, data.indx_t3_2 ,data.indx_t3_3);
  chi2_v2 = vecnorm((v2_model - data.v2)./data.v2_err)^2;
  chi2_t3amp = vecnorm((t3amp_model - data.t3amp)./data.t3amp_err)^2;
  chi2_t3phi = vecnorm(mod360(t3phi_model - data.t3phi)./data.t3phi_err)^2;
  g_v2 = real(transpose(dft[data.indx_v2,:])*(4*((v2_model-data.v2)./data.v2_err.^2).*conj(cvis_model[data.indx_v2])));
  g_t3amp = real(transpose(dft[data.indx_t3_1,:])*(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*conj(cvis_model[data.indx_t3_1])./abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_2]).*abs.(cvis_model[data.indx_t3_3]) ))+real(transpose(dft[data.indx_t3_2,:])*(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*conj(cvis_model[data.indx_t3_2])./abs.(cvis_model[data.indx_t3_2]).*abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_3]) ))+real(transpose(dft[data.indx_t3_3,:])*(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*conj(cvis_model[data.indx_t3_3])./abs.(cvis_model[data.indx_t3_3]).*abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_2]) ))
  g_t3phi = 360./pi*imag(transpose(dft[data.indx_t3_1,:])*(((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*cvis_model[data.indx_t3_2].*cvis_model[data.indx_t3_3].*conj(t3_model))
                        +transpose(dft[data.indx_t3_2,:])*(((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*cvis_model[data.indx_t3_1].*cvis_model[data.indx_t3_3].*conj(t3_model))
                        +transpose(dft[data.indx_t3_3,:])*(((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*cvis_model[data.indx_t3_1].*cvis_model[data.indx_t3_2].*conj(t3_model)))

  g[:] = g_v2 + g_t3amp+ g_t3phi;
  flux = sum(x);
  g[:] = (g - sum(x.*g) / flux ) / flux; # gradient correction to take into account the non-normalized image
  println("V2: ", chi2_v2/data.nv2, " T3A: ", chi2_t3amp/data.nt3amp, " T3P: ", chi2_t3phi/data.nt3phi," Flux: ", flux)
  return chi2_v2 + chi2_t3amp + chi2_t3phi
end

function chi2_nfft_fg(x, g, fftplan_uv, fftplan_v2, fftplan_t3_1,fftplan_t3_2, fftplan_t3_3, data ) # criterion function plus its gradient w/r x
  cvis_model = image_to_cvis_nfft(x, fftplan_uv);
  v2_model = cvis_to_v2(cvis_model, data.indx_v2);
  t3_model, t3amp_model, t3phi_model = cvis_to_t3(cvis_model, data.indx_t3_1, data.indx_t3_2 ,data.indx_t3_3);
  chi2_v2 = vecnorm((v2_model - data.v2)./data.v2_err)^2;
  chi2_t3amp = vecnorm((t3amp_model - data.t3amp)./data.t3amp_err)^2;
  chi2_t3phi = vecnorm(mod360(t3phi_model - data.t3phi)./data.t3phi_err)^2;
  g_v2 = real(nfft_adjoint(fftplan_v2, (4*((v2_model-data.v2)./data.v2_err.^2).*cvis_model[data.indx_v2])));
  g_t3amp = real(nfft_adjoint(fftplan_t3_1, (2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*cvis_model[data.indx_t3_1]./abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_2]).*abs.(cvis_model[data.indx_t3_3]) ))) + real(nfft_adjoint(fftplan_t3_2,(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*cvis_model[data.indx_t3_2]./abs.(cvis_model[data.indx_t3_2]).*abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_3]) ))) +real(nfft_adjoint(fftplan_t3_3,(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*cvis_model[data.indx_t3_3]./abs.(cvis_model[data.indx_t3_3]).*abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_2]) )))
  g_t3phi = -360./pi*imag(nfft_adjoint(fftplan_t3_1, ((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*conj(cvis_model[data.indx_t3_2].*cvis_model[data.indx_t3_3]).*t3_model)
                        +nfft_adjoint(fftplan_t3_2, ((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*conj(cvis_model[data.indx_t3_1].*cvis_model[data.indx_t3_3]).*t3_model)
                        +nfft_adjoint(fftplan_t3_3, ((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*conj(cvis_model[data.indx_t3_1].*cvis_model[data.indx_t3_2]).*t3_model))

  g[:] = vec(g_v2 + g_t3amp+ g_t3phi);
  flux = sum(x);
  g[:] = (g - sum(x.*g) / flux ) / flux; # gradient correction to take into account the non-normalized image
  println("V2: ", chi2_v2/data.nv2, " T3A: ", chi2_t3amp/data.nt3amp, " T3P: ", chi2_t3phi/data.nt3phi," Flux: ", flux)
  return chi2_v2 + chi2_t3amp + chi2_t3phi
end




function chi2_vis_dft_fg(x, g, dft, data ) # criterion function plus its gradient w/r x
  cvis_model = image_to_cvis_dft(x, dft);
  # compute observables from all cvis
  visamp_model = abs.(cvis_model);
  visphi_model = angle.(cvis_model)*(180./pi);
  chi2_visamp = vecnorm((visamp_model - data.visamp)./data.visamp_err)^2;
  chi2_visphi = vecnorm(mod360(visphi_model - data.visphi)./data.visphi_err)^2;
  # Original formulas
  # g_visamp = 2*sum(((visamp_model-data.visamp)./data.visamp_err.^2).*real( conj(cvis_model./visamp_model).*dft),1);
  # g_visphi = 360./pi*sum(((mod360(visphi_model-data.visphi)./data.visphi_err.^2)./abs2.(cvis_model)).*(-imag(cvis_model).*real(dft)+real(cvis_model).*imag(dft)),1);
  # Improved formulas
  g_visamp = 2.0*real(transpose(dft)*(conj(cvis_model./visamp_model).*(visamp_model-data.visamp)./data.visamp_err.^2))
  g_visphi = 360./pi*imag(transpose(dft)*((mod360(visphi_model-data.visphi)./data.visphi_err.^2)./visamp_model.^2.*conj(cvis_model)));
  g[:] = g_visamp + g_visphi;
  flux = sum(x);
  g[:] = (g - sum(x.*g) / flux ) / flux; # gradient correction to take into account the non-normalized image
#  imdisp(x);
  println("VISAMP: ", chi2_visamp/data.nvisamp, " VISPHI: ", chi2_visphi/data.nvisphi, " Flux: ", flux)
  return chi2_visamp + chi2_visphi
end

function chi2_vis_nfft_fg(x, g, fftplan, data ) # criterion function plus its gradient w/r x
  cvis_model = image_to_cvis_nfft(x, fftplan);
  # compute observables from all cvis
  visamp_model = abs.(cvis_model);
  visphi_model = angle.(cvis_model)*(180./pi);
  chi2_visamp = vecnorm((visamp_model - data.visamp)./data.visamp_err)^2;
  chi2_visphi = vecnorm(mod360(visphi_model - data.visphi)./data.visphi_err)^2;
  g_visamp = 2.0*real(nfft_adjoint(fftplan,(cvis_model./visamp_model.*(visamp_model-data.visamp)./data.visamp_err.^2)));
  g_visphi = 360./pi*-imag(nfft_adjoint(fftplan,cvis_model.*((mod360(visphi_model-data.visphi)./data.visphi_err.^2)./visamp_model.^2)));
  g[:] = vec(g_visamp + g_visphi);
  flux = sum(x);
  g[:] = (g - sum(x.*g) / flux ) / flux; # gradient correction to take into account the non-normalized image
  println("VISAMP: ", chi2_visamp/data.nvisamp, " VISPHI: ", chi2_visphi/data.nvisphi, " Flux: ", flux)
  return chi2_visamp + chi2_visphi
end

function gaussian2d(n,m,sigma)
  g2d = [exp(-((X-(m/2)).^2+(Y-n/2).^2)/(2*sigma.^2)) for X=1:m, Y=1:n]
  return g2d
end

function cdg(x) #note: this takes a 2D array
  xvals=[i for i=1:size(x,1)]
  return [sum(xvals'*x) sum(x*xvals)]/sum(x)
end

function reg_centering(x,g) # takes a 1D array
  nx = Int(sqrt(length(x)))
  flux= sum(x)
  c = cdg(reshape(x,nx,nx))
  f = (c[1]-(nx+1)/2)^2+(c[2]-(nx+1)/2)^2
  xx = [mod(i-1,nx)+1 for i=1:nx*nx]
  yy = [div(i-1,nx)+1 for i=1:nx*nx]
  g[1:nx*nx] = 2*(c[1]-(nx+1)/2)*xx + 2*(c[2]-(nx+1)/2)*yy
  return f
end
#
# function chi2_centered_l2_fg(x, g, mu, dft, data )
# flux = sum(x);
# cvis_model = image_to_cvis_dft(x, dft);
# v2_model = cvis_to_v2(cvis_model, data.indx_v2);
# t3_model, t3amp_model, t3phi_model = cvis_to_t3(cvis_model, data.indx_t3_1, data.indx_t3_2 ,data.indx_t3_3);
# # centering
#   rho = 1e4
#   reg_der = zeros(size(x))
#   reg = reg_centering(x, reg_der)
# # L2
#   l2 = sum(x.^2)
#   l2_der = 2*x
#   # note: this is correct but slower
#   chi2_v2 = vecnorm((v2_model - data.v2)./data.v2_err)^2;
#   chi2_t3amp = vecnorm((t3amp_model - data.t3amp)./data.t3amp_err)^2;
#   chi2_t3phi = vecnorm(mod360(t3phi_model - data.t3phi)./data.t3phi_err)^2;
#   g_v2 = real(transpose(dft[data.indx_v2,:])*(4*((v2_model-data.v2)./data.v2_err.^2).*conj(cvis_model[data.indx_v2])));
#   g_t3amp = real(transpose(dft[data.indx_t3_1,:])*(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*conj(cvis_model[data.indx_t3_1])./abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_2]).*abs.(cvis_model[data.indx_t3_3]) ))+real(transpose(dft[data.indx_t3_2,:])*(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*conj(cvis_model[data.indx_t3_2])./abs.(cvis_model[data.indx_t3_2]).*abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_3]) ))+real(transpose(dft[data.indx_t3_3,:])*(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*conj(cvis_model[data.indx_t3_3])./abs.(cvis_model[data.indx_t3_3]).*abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_2]) ))
#   g_t3phi = 360./pi*imag(transpose(dft[data.indx_t3_1,:])*(((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*cvis_model[data.indx_t3_2].*cvis_model[data.indx_t3_3].*conj(t3_model))
#                         +transpose(dft[data.indx_t3_2,:])*(((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*cvis_model[data.indx_t3_1].*cvis_model[data.indx_t3_3].*conj(t3_model))
#                         +transpose(dft[data.indx_t3_3,:])*(((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*cvis_model[data.indx_t3_1].*cvis_model[data.indx_t3_2].*conj(t3_model)))
#
#   imdisp(x)
#   g[1:end] =  +  rho * reg_der + mu * l2_der;
#   g[1:end] = (g - sum(vec(x).*g) / flux ) / flux; # gradient correction to take into account the non-normalized image
#   println("V2: ", chi2_v2/data.nv2, " T3A: ", chi2_t3amp/data.nt3amp, " T3P: ", chi2_t3phi/data.nt3phi," Flux: ", flux, " CENT: ", reg, " COG ", cdg(reshape(x,nx,nx)), " L2: ", mu*l2)
#   return chi2_v2 + chi2_t3amp + chi2_t3phi + rho *reg + mu * l2
# end



function chi2_centered_fg(x::Array{Float64,1}, g::Array{Float64,1}, dft::Array{Complex{Float64},2}, data::OIdata)
  flux = sum(x);
  cvis_model = image_to_cvis_dft(x, dft);
# cvis_model = image_to_cvis_nfft(x, fft);
  # compute observables from all cvis
  #tic();
  v2_model = cvis_to_v2(cvis_model, data.indx_v2);
  t3_model, t3amp_model, t3phi_model = cvis_to_t3(cvis_model, data.indx_t3_1, data.indx_t3_2 ,data.indx_t3_3);

# centering
  rho = 1e4
  cent_g = zeros(size(x))
  cent_f = reg_centering(x, cent_g)
  # note: this is correct but slower
  chi2_v2 = vecnorm((v2_model - data.v2)./data.v2_err)^2;
  chi2_t3amp = vecnorm((t3amp_model - data.t3amp)./data.t3amp_err)^2;
  chi2_t3phi = vecnorm(mod360(t3phi_model - data.t3phi)./data.t3phi_err)^2;
  g_v2 = real(transpose(dft[data.indx_v2,:])*(4*((v2_model-data.v2)./data.v2_err.^2).*conj(cvis_model[data.indx_v2])));
  g_t3amp = real(transpose(dft[data.indx_t3_1,:])*(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*conj(cvis_model[data.indx_t3_1])./abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_2]).*abs.(cvis_model[data.indx_t3_3]) ))+real(transpose(dft[data.indx_t3_2,:])*(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*conj(cvis_model[data.indx_t3_2])./abs.(cvis_model[data.indx_t3_2]).*abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_3]) ))+real(transpose(dft[data.indx_t3_3,:])*(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*conj(cvis_model[data.indx_t3_3])./abs.(cvis_model[data.indx_t3_3]).*abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_2]) ))
  g_t3phi = 360./pi*imag(transpose(dft[data.indx_t3_1,:])*(((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*cvis_model[data.indx_t3_2].*cvis_model[data.indx_t3_3].*conj(t3_model))
                         +transpose(dft[data.indx_t3_2,:])*(((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*cvis_model[data.indx_t3_1].*cvis_model[data.indx_t3_3].*conj(t3_model))
                         +transpose(dft[data.indx_t3_3,:])*(((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*cvis_model[data.indx_t3_1].*cvis_model[data.indx_t3_2].*conj(t3_model)))
  g[:] = g_v2 + g_t3amp + g_t3phi +  rho * cent_g;
  g[:] = (g - sum(vec(x).*g) / flux ) / flux; # gradient correction to take into account the non-normalized image
  println("V2: ", chi2_v2/data.nv2, " T3A: ", chi2_t3amp/data.nt3amp, " T3P: ", chi2_t3phi/data.nt3phi," Flux: ", flux, " CENT: ", cent_f, " CDG ", cdg(reshape(x,nx,nx)))
  return chi2_v2 + chi2_t3amp + chi2_t3phi + rho * cent_f
end




function chi2_centered_nfft_fg(x::Array{Float64,1}, g::Array{Float64,1}, fftplan_uv, fftplan_v2, fftplan_t3_1,fftplan_t3_2, fftplan_t3_3,data::OIdata)
  flux = sum(x);
# centering
  rho = 1e4
  cent_g = zeros(size(x))
  cent_f = reg_centering(x, cent_g)
# Likelihood
  cvis_model = image_to_cvis_nfft(x, fftplan_uv);
  v2_model = cvis_to_v2(cvis_model, data.indx_v2);
  t3_model, t3amp_model, t3phi_model = cvis_to_t3(cvis_model, data.indx_t3_1, data.indx_t3_2 ,data.indx_t3_3);
  chi2_v2 = vecnorm((v2_model - data.v2)./data.v2_err)^2;
  chi2_t3amp = vecnorm((t3amp_model - data.t3amp)./data.t3amp_err)^2;
  chi2_t3phi = vecnorm(mod360(t3phi_model - data.t3phi)./data.t3phi_err)^2;
  g_v2 = real(nfft_adjoint(fftplan_v2, (4*((v2_model-data.v2)./data.v2_err.^2).*cvis_model[data.indx_v2])));
  g_t3amp = real(nfft_adjoint(fftplan_t3_1, (2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*cvis_model[data.indx_t3_1]./abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_2]).*abs.(cvis_model[data.indx_t3_3]) ))) + real(nfft_adjoint(fftplan_t3_2,(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*cvis_model[data.indx_t3_2]./abs.(cvis_model[data.indx_t3_2]).*abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_3]) ))) +real(nfft_adjoint(fftplan_t3_3,(2.0*((t3amp_model-data.t3amp)./data.t3amp_err.^2).*cvis_model[data.indx_t3_3]./abs.(cvis_model[data.indx_t3_3]).*abs.(cvis_model[data.indx_t3_1]).*abs.(cvis_model[data.indx_t3_2]) )))
  g_t3phi = -360./pi*imag(nfft_adjoint(fftplan_t3_1, ((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*conj(cvis_model[data.indx_t3_2].*cvis_model[data.indx_t3_3]).*t3_model)
                        +nfft_adjoint(fftplan_t3_2, ((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*conj(cvis_model[data.indx_t3_1].*cvis_model[data.indx_t3_3]).*t3_model)
                        +nfft_adjoint(fftplan_t3_3, ((mod360(t3phi_model-data.t3phi)./data.t3phi_err.^2)./abs2.(t3_model)).*conj(cvis_model[data.indx_t3_1].*cvis_model[data.indx_t3_2]).*t3_model))
  g[:] = vec(g_v2 + g_t3amp + g_t3phi) +  rho * cent_g;
  g[:] = (g - sum(vec(x).*g) / flux ) / flux; # gradient correction to take into account the non-normalized image
  println("V2: ", chi2_v2/data.nv2, " T3A: ", chi2_t3amp/data.nt3amp, " T3P: ", chi2_t3phi/data.nt3phi," Flux: ", flux, " CENT: ", cent_f, " CDG ", cdg(reshape(x,nx,nx)))
  return chi2_v2 + chi2_t3amp + chi2_t3phi + rho * cent_f
end
