use_single_specified_video = false;
only_smallest_video = false;

if ( use_single_specified_video )
  vid_ps = {'/Users/nick/source/changlab/jamie/fv_task/videos/clip_0.mp4.avi'};
else
  vid_ps = shared_utils.io.find( fullfile(project_directory, 'videos'), '.avi' );

  if ( only_smallest_video )
    dirs = cellfun( @dir, vid_ps );
    [~, min_s] = min( [dirs.bytes] );
    vid_ps = vid_ps(min_s);
  end
end

for i = 1:numel(vid_ps)

vid_p = vid_ps{i};
  
frame_scrambler = ptb.Reference();
frame_scrambler.Value.frame_index = 1;

dst_p = fullfile( fileparts(vid_p), 'scrambled' );
make_video_clips( vid_p, dst_p, [], [], @(f) do_scramble(frame_scrambler, f) );

end

%%

function frame = do_scramble(ref, frame)

v = ref.Value;

src_f = double( frame ) ./ 255;
f = src_f;

if ( v.frame_index == 1 )
  % first frame
  ang_shift = repmat( (rand(size(f, [1, 2])) * 2 - 1) * pi, [1, 1, 3] );
  v.angle_shift = ang_shift;
  v.min_s = zeros( 1, 3 );
  v.max_s = zeros( 1, 3 );
  v.lum = [ mean2(src_f), std2(src_f) ];
end
  
for i = 1:size(f, 3)
  ct = fft2( f(:, :, i) );
  mag = abs( ct );
  ang = angle( ct );
  ang = ang + v.angle_shift(:, :, i);
  ft = abs( ifft2(mag .* exp(1i * ang)) );
  f(:, :, i) = ft;
end

lum_f = zeros( size(f) );
for i = 1:size(f, 3)   
  ft = f(:, :, i);
  st = src_f(:, :, i) * 255;
  
  min_v = min( reshape(ft, [], 1) );
  max_v = max( reshape(ft, [], 1) );
  ft = 255 * (ft - min_v) ./ (max_v - min_v);
  
  l = lumMatch( {ft}, [], [mean2(st), std2(st)] );
  lum_f(:, :, i) = l{1};
end
f = lum_f;

if ( 0 )
  figure(1); subplot( 1, 2, 1 );
  imshow( src_f );

  subplot( 1, 2, 2 );
  imshow( lum_f ./ 255 )
end

%%

f = uint8( f );

v.frame_index = v.frame_index + 1;
ref.Value = v;

frame = f;

end


function images = lumMatch(images,mask,lum) 

% ------------------------------------------------------------------------
% SHINE toolbox, May 2010
% (c) Verena Willenbockel, Javid Sadr, Daniel Fiset, Greg O. Horne,
% Frederic Gosselin, James W. Tanaka
% ------------------------------------------------------------------------
% Permission to use, copy, or modify this software and its documentation
% for educational and research purposes only and without fee is hereby
% granted, provided that this copyright notice and the original authors'
% names appear on all copies and supporting documentation. This program
% shall not be used, rewritten, or adapted as the basis of a commercial
% software or hardware product without first obtaining permission of the
% authors. The authors make no representations about the suitability of
% this software for any purpose. It is provided "as is" without express
% or implied warranty.
%
% Please refer to the following paper:
% Willenbockel, V., Sadr, J., Fiset, D., Horne, G. O., Gosselin, F.,
% Tanaka, J. W. (2010). Controlling low-level image properties: The
% SHINE toolbox. Behavior Research Methods, 42, 671-684.
%
% Kindly report any suggestions or corrections to verena.vw@gmail.com
% ------------------------------------------------------------------------
% SHINE_color toolbox, September 2021, version 0.0.3
% (c) Rodrigo Dal Ben (dalbenwork@gmail.com)
%
% Replace 'rgb2gray' for 'lum2scale' function
% ------------------------------------------------------------------------
% SHINE_color toolbox, March 2023, version 0.0.5
% (c) Rodrigo Dal Ben (dalbenwork@gmail.com)
%
% Remove transformations, all is done under readImages
% ------------------------------------------------------------------------

if iscell(images) == 0
    error('The input must be a cell.')
elseif min(size(images)>1)
    error('The input cell must be of size 1 x numim or numim x 1.')
end

if nargin > 1
    if iscell(mask) == 0
        m = mask;
    elseif max(size(mask))~=max(size(images))||min(size(mask))~=min(size(images))
        error('The size of the input cells must be equal.')
    end
end

numim = max(size(images));
if nargin == 1
    M = 0; 
    S = 0;
    
    for im = 1:numim
        M = M + mean2(images{im});
        S = S + std2(images{im});
    end
    
    M = M/numim;
    S = S/numim;
        
    for im = 1:numim
        im1 = double(images{im});
        if std2(im1)~=0
            im1 = (im1-mean2(im1))/std2(im1)*S+M;
        else
            im1(:,:) = M;
        end
        images{im} = uint8(im1);
    end
    
elseif nargin == 2
    M = 0; S = 0;
    for im = 1:numim
        im1 = images{im};
        if iscell(mask) == 1
            m = mask{im};
        end
        if sum(size(m)~=size(images{im}))>0
            error('The size of the mask must equal the size of the image.')
        elseif numel(m(m==1))==0
            error('The mask must contain some ones.')
        end
        M = M + mean2(im1(m==1));
        S = S + std2(im1(m==1));
    end
    M = M/numim;
    S = S/numim;
    for im = 1:numim
        im1 = double(images{im});
        if iscell(mask) == 1
            m = mask{im};
        end
        if std2(im1(m==1))
            im1(m==1) = (im1(m==1)-mean2(im1(m==1)))/std2(im1(m==1))*S+M;
        else
            im1(m==1) = M;
        end
        images{im} = uint8(im1);
    end
elseif nargin == 3
    M = lum(1); S = lum(2);
    for im = 1:numim
        im1 = double(images{im});
        if isempty(mask) == 1
            if std2(im1) ~= 0
                im1 = (im1-mean2(im1))/std2(im1)*S+M;
            else
                im1(:,:) = M;
            end
        else
            if iscell(mask) == 1
                m = mask{im};
            end
            if sum(size(m)~=size(images{im}))>0
                error('The size of the mask must equal the size of the image.')
            elseif numel(m(m==1)) == 0
                error('The mask must contain some ones.')
            end
            if std2(im1(m==1)) ~= 0
                im1(m==1) = (im1(m==1)-mean2(im1(m==1)))/std2(im1(m==1))*S+M;
            else
                im1(m==1) = M;
            end
        end
        images{im} = uint8(im1);
    end
end

end