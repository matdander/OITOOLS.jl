using OITOOLS

#EXAMPLE 8
#Simulate an observation using an input image, given telescope parameters, and input hour angles

dates=[2018 8 13 5 13 56.7; 2018 8 13 5 15 56.7; 2018 8 13 5 20 56.7; 2018 8 13 5 25 56.7; 2018 8 13 5 30 56.7;
       2018 8 13 6 15 56.7; 2018 8 13 6 20 56.7; 2018 8 13 6 25 56.7; 2018 8 13 6 30 56.7; 2018 8 13 7 15 56.7;
       2018 8 13 7 20 56.7; 2018 8 13 7 25 56.7; 2018 8 13 7 30 56.7; 2018 8 15 5 13 56.7; 2018 8 15 5 15 56.7;
       2018 8 15 5 20 56.7; 2018 8 15 5 25 56.7; 2018 8 15 5 30 56.7; 2018 8 15 6 15 56.7; 2018 8 15 6 20 56.7;
       2018 8 15 6 25 56.7; 2018 8 15 6 30 56.7; 2018 8 15 7 15 56.7; 2018 8 15 7 20 56.7; 2018 8 15 7 25 56.7;
       2018 8 15 7 30 56.7; 2018 8 18 5 13 56.7; 2018 8 18 5 15 56.7; 2018 8 18 5 20 56.7; 2018 8 18 5 25 56.7;
       2018 8 18 5 30 56.7; 2018 8 18 6 15 56.7; 2018 8 18 6 20 56.7; 2018 8 18 6 25 56.7; 2018 8 18 6 30 56.7;
       2018 8 18 7 15 56.7; 2018 8 18 7 20 56.7; 2018 8 18 7 25 56.7; 2018 8 18 7 30 56.7;]

ra=20+57/60+59.44/3600

longitude=118.0570313111
v2m=1.0/100
v2a=1e-5
t3ampm=1.0/100
t3ampa=1e-6
t3phim=0.0
t3phia=0.5

lsts,hour_angles=hour_angle_calc(dates,longitude,ra);
# lst_hours=floor.(lsts)
# lstmin=floor.((lsts.-floor.(lsts)).*60)
# lstsec=(((lsts.-floor.(lsts)).*60)-floor.(lstmin))*60

image_file="./data/2004true.fits";
pixsize=0.101;
out_file="!./data/2004testsimulation.oifits";

facility    = read_facility_file("./data/example_facility_config.txt");
observatory = read_obs_file("./data/example_obs_config.txt");
combiner    = read_comb_file("./data/example_combiner_config.txt");
wave        = read_wave_file("./data/example_wave_config.txt");
errors      = define_errors(v2m,v2a,t3ampm,t3ampa,t3phim,t3phia);

simulate_ha(facility, observatory, combiner, wave, hour_angles, image_file, pixsize, errors, out_file);

#Compare simulated data to original data

#display the image
fitsfile = "./data/2004true.fits";
pixsize = 0.101; # in mas/pixel
x_true = readfits(fitsfile); nx = (size(x_true))[1]; x_true=vec(x_true);
imdisp(x_true, pixscale = pixsize, tickinterval = 1.0, beamsize = 1.0, beamlocation = [0.85, 0.85])
#read the data file

oifitsfile = "./data/2004testsimulation.oifits";
data = (readoifits(oifitsfile))[1,1]; # data can be split by wavelength, time, etc.

# NFFT method
ft = setup_nfft(data, nx, pixsize);
# This computes the complete chi2
f_chi2 = chi2_nfft_f(x_true, ft, data);
# Compute |V|^2 observables and plot
cvis_model = image_to_cvis_nfft(x_true, ft);
v2_model = cvis_to_v2(cvis_model, data.indx_v2);
v2plot_modelvsdata(data.v2_baseline,data.v2,data.v2_err, v2_model,logplot=true);
