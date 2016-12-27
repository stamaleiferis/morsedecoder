%%  Morse code envelope extraction and decoding
%   Stamatios Aleiferis
%   ES2 Project

%% morse_decode.m
% this script asks the user for an mp3 audio file containing a morse code
% message and proccesses the file. It plots the signal and after proccessing it it plots 
% the periods of dashes/dots and silence. It stores the sequence of
% dashes/dots/blanks in a cell array

%% For development:
%  1)write an algorithm that "breaks" the cell array of the sequence of
%  dashes/dots and silence in to cell arrays containing words(this will be done
%  by identifying the longer periods of silence)
%  2)write an algorithm that "breaks" the cell arrays containing words into
%  cell arrays containing letters(this will be done by identifying the
%  second longest periods of silence)
%  3)Compare the letters to a map that correlates dash/dot sequence into
%  letters of the alphabet. Combine results to give back the translated
%  text

%%
[file,path]=uigetfile('*.mp3*','Select an audio file(.mp3)');  % ask for mp3 file
[y, Fs] = audioread(file) ; %read mp3 file

%dur = 4;
%smpl=y(1:dur*Fs);

avgsec = 0.02 ; %time to average over
smpl = y ; %create copy of data vector
figure(1)
plot(smpl)
title('Input audio signal')
saveas(figure(1), 'Input audio signal', 'jpg')

[smpl]= envExtract(smpl, avgsec, Fs); %call envelope extraction function
figure(2)
plot(smpl)
title('Smoothed signal')
saveas(figure(2), 'Smoothed signal', 'jpg')

amplThresh = 0.4 ;  %amplitude threshold used to detect dashes and dots

logic = smpl>amplThresh ; %create logical array of dashes and dots

figure(3)
plot(logic)
title('Identified dashes/dots')
saveas(figure(3), 'Identified dashes and dots', 'jpg')

%% create new logical vector without the silence in the beginning and end
non_zero = find(logic); %find indices of nonzero elements in logic
logic=logic(non_zero(1):non_zero(end));

%% calculate datThresh, dotThresh, charThresh, wordThresh

% blanks: each element represents the duration(in number of samples) of
%           silence between dashes and dots
% data: each element represents the duration of a noise(dash or dot)

logic(end+1)=0;
counter_data=1;
counter_blanks=1;
data_pos=1;
blanks_pos=1;

for dl=2:length(logic)
    add=logic(dl)+logic(dl-1);
    if add==2 || (add==1 && counter_blanks~=1)
        counter_data=counter_data+1;
        if counter_blanks~=1
            blanks(blanks_pos)=counter_blanks;
            blanks_pos=blanks_pos+1;
            counter_blanks=1;
        end
    elseif add==0 || (add==1 && counter_data~=1)    
        counter_blanks=counter_blanks+1;
        if counter_data~=1
            data(data_pos)=counter_data;
            data_pos=data_pos+1;
            counter_data=1;
        end
    end
end
            
sorted_data=sort(data);
sorted_blanks=sort(blanks);
diffVec=diff(sorted_blanks);

for d=2:length(data)
    if sorted_data(d)-sorted_data(d-1)> 3000
        dashVector=sorted_data(d:end);
        dotVector=sorted_data(1:d-1) ;
    end
end

dasThresh=min(dashVector);
dotThresh=min(dotVector) ;

     c=1;
     vec1(c)=sorted_blanks(c);
    while diffVec(c)<7000
         vec1(c+1)=sorted_blanks(c+1);
         c=c+1;
    end
    diffVec(1:c)=[];
    sorted_blanks(1:c)=[];
    
    c=1;
    vec2(c)=sorted_blanks(c);
    while diffVec(c)<13000
        vec2(c+1)=sorted_blanks(c+1);
        c=c+1;
    end
    diffVec(1:c)=[];
    sorted_blanks(1:c)=[];

    
    vec3=sorted_blanks ;
    charThresh=min(vec1);
    letterThresh=min(vec2);
    wordThresh=min(vec3) ;
%% detect dashes and dots and spaces and update morse map
%   spaces between words are represented by the string 'w'
%   spaces between letters are represented by the string 'l'
logic(end+1)=0;
num_sample=0;
num_zeros=0;
morse_counter=1;
for j=1:length(logic)

     if logic(j)==1
         num_sample=num_sample+1;
         if num_zeros~=0
             if num_zeros>wordThresh
                %update
                morse_map{morse_counter}='w' ;
                morse_counter=morse_counter+1;
                num_zeros=0;
            elseif num_zeros>letterThresh
             %update and reset            
             morse_map{morse_counter}='l' ;
             morse_counter=morse_counter+1;
             num_zeros=0;
            elseif num_zeros>charThresh                       
             num_zeros=0;
             end
         end
     elseif logic(j)==0
         num_zeros=num_zeros+1;
         if num_sample ~= 0
             if num_sample>dasThresh
                 %update and reset
                 morse_map{morse_counter}='-' ;
                 morse_counter=morse_counter+1;
                 num_sample=0;
             elseif num_sample>dotThresh
                 %update
                 morse_map{morse_counter}='.' ;
                 morse_counter=morse_counter+1;
                 num_sample=0;
             end
         end
     end
end
 
%% Extract the map of dashes, dots and spaces to a cell array 
%   each element of the cell array is a word

word_count=1;
char_count=1;

for mm=1:length(morse_map)
    if morse_map{mm} == 'w' ;
        word_count=word_count+1;
        char_count=1 ;
    else
        words{word_count}(char_count) = morse_map(mm);
        char_count=char_count+1;
    end
end
    
save('morse_map.mat', 'morse_map')