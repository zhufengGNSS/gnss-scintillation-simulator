 function   SPEC_Summary=PSDScaleSpec0(data,nsamp,nsamp_seg,nsegs,dx,S_data,J,jmax)
%USAGE:    SPEC_Summary=PSDScaleSpec(data,nsamp,nsamp_seg,nsegs,dx,S_data,J,jmax)
%
%PURPOSE   Process & classify segmented scale spectra generated by ComputeDWT and ComputeScaleSpectrum
%
%INPUT:
%          data  =data array
%          nsamp =length(data)
%          nsamp_seg  =length of segments
%          nseg  =number of segments
%          S_data,J,jmax outputs from ComputeScaleSpectrum
%
%OUTPUT:
%          SPEC_Summary{}.SPEC= nsegs cell array of summary data
%          SPEC fields
%               data_seg  =data samples
%               xxPSD     = log10(frequency scale)
%               yyPSD     = 10log10(PSD)
%               yy0       = least squares polynomial fit or PSD at scale spec samples
%               xxScale   = log10(DWT scales)
%               yyScale   = 10log10(ScaleSpec)
%               offset    = dB offset to align Scale Spec with PSD
%NOCLASSIFICATION
%
%SUBROUTINES: pdgm, dB10
%

sj=(2*dx)*2.^(J-1-jmax:-1:0);
qScale=1./sj;
qfft=(0:nsamp_seg/2)*(1/dx/nsamp_seg);

SPEC_Summary=cell(1,nsegs);
SPEC=struct('data_seg',[],'xxPSD',[],'yyPSD',[],'yy0',[],'xxScale',[],'yyScale',[],'offset',[]);
noff=0;
for nseg=1:nsegs
    n1=(nseg-1)*nsamp_seg+1; n2=n1+nsamp_seg-1;
    if n2>nsamp
        break
    end
    data_seg=data(n1:n2);
    %Conventional unweighted raw PSD
    [psd,~] = pdgm(data_seg,nsamp_seg,noff);
    xxPSD=log10(qfft(2:nsamp_seg/2));
    yyPSD=dB10(psd(2:nsamp_seg/2)/2);
    
    %Scale spectrum interpolated to xxPSD
    xxScale=log10(qScale);
    yyScale=dB10(S_data(jmax:J-1,nseg))';
    
    [P0,S,MU] = polyfit(xxPSD,yyPSD,8);
    yy0=polyval(P0,xxScale,S,MU);
    offset=(sum(yy0)-sum(yyScale))/length(yy0);
    %yyScale=yyScale+offset;
    
    SPEC.data_seg=data_seg;
    SPEC.xxPSD   =xxPSD;
    SPEC.yyPSD   =yyPSD;
    SPEC.yy0     =yy0;
    SPEC.xxScale =xxScale;
    SPEC.yyScale =yyScale;
    SPEC.offset  =offset;
    SPEC_Summary{nseg}=SPEC;  
end %End of segment
return