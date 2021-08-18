function [Sample] = ridgeTracking_wrapper(thisExp,Sample,sample,i)
% So we don't have to look at all this in the main workflow.

% MTJ 10AUG2021

    startpath = cd();

%% Get the data out:
%         matrix = vertcat(thisExp.smoothedData(thisExp.traceMats).data);
%             matrix = matrix(thisExp.plotInds{:},:);
% 
        matrix = thisExp.matrix;
        ppm = thisExp.ppm;
        
        timepoints = vertcat(thisExp.smoothedTimes(thisExp.traceMats).timepoints(:));
            timepoints = timepoints(thisExp.plotInds{:});
            
%         plotTitle = thisExp.plotTitle;        

        regionsele = thisExp.trackingRegions;
        wander_settingByRegion = thisExp.wander_settingByRegion;
        intensityVariation_ByRegion = thisExp.intensityVariation_ByRegion;
        
            
%% Plot to make sure the spectra look good. Params used for plotting later?

    thisExp.horzshift = .002;
    thisExp.vertshift = 1E-2;



    mkdir('Production_Run')
    cd Production_Run

    for samp_i_i = 1:length(sample)
            % if samp_i~ = 1
            %   showfig = openfig(strcat(path,showfigtitle,'.surf.experiment.manual.fig'));
            % end
            
            % Get the data
                samp_i = sample(samp_i_i);
                fprintf(['\n\n\t\t\t','sample ' num2str(samp_i) ' region ' num2str(i),'\n\n']);
                currentTrackingRegion = regionsele(i,:);
                plotTitle = [num2str(currentTrackingRegion(1)),'.',num2str(currentTrackingRegion(2)),'.',num2str(samp_i),'.testplot'];
            
            % Run the Function
            try
                [returndata] = ridgetrace_power2_ext(matrix,ppm,timepoints,currentTrackingRegion,path,wander_settingByRegion(i),intensityVariation_ByRegion(i));
            catch 
                warning('Program terminated prematurely. Data were not saved.');
                cd(startpath)
                return
            end
            % Save the figure    
                fig = gcf;
%                 saveas(fig,strcat(cd(),'/',plotTitle,'.surf.experiment.manual.fig'));
                if samp_i == 1
                  showfigtitle = plotTitle;
                end
                close(fig);
                
            % Store the data?
                if ~isempty(fieldnames(returndata))
                    result = returndata.result;
                    ridnames = returndata.names;
                    quanvec = returndata.quantifyvec;
                    groups = result(:,5);
                else
                    warning('No data were saved')
                    return
                end
                
            % Store as a struct table
            
                tempstorerids = [];
                tempstorerids.ridges(1).parameters = [];
                tempstorerids.ridges(1).result = [];
                for group = unique(groups,'stable')'
                  groupind = find(result(:,5) == group);
                  temptab = result(groupind,:);
                  temptab(:,5) = [];
                  resdata = struct();
                  resdata.linearind = temptab(:,1);
                  resdata.colind = temptab(:,2);
                  resdata.rowind = temptab(:,3);
                  resdata.intensity = temptab(:,4);
                  resdata.names = ridnames(groupind);
                  resdata.quanvec = quanvec(groupind);
                  resdata.time = temptab(:,5);
                  resdata.ppm = temptab(:,6);
                  res = struct();
                  res.parameters = returndata.para;
                  res.result = resdata;
                  Sample(samp_i_i).ridges = [Sample(samp_i_i).ridges res];
                  tempstorerids.ridges = [tempstorerids.ridges res];
                end
            
%%            % Make the structure for plotting
            
                peakshere = struct();
                ridgenumbers = 1:length(tempstorerids.ridges);
                for scali = 1:length(ridgenumbers)
                  if ~isempty(tempstorerids.ridges(ridgenumbers(scali)).result)
                    % peakshere(scali).Ridges = ppm(tempstorerids.ridges(ridgenumbers(scali)).result.colind);
                    peakshere(scali).Ridges = tempstorerids.ridges(ridgenumbers(scali)).result.ppm';
                    peakshere(scali).RowInds = tempstorerids.ridges(ridgenumbers(scali)).result.rowind';
                    peakshere(scali).RidgeIntensities = tempstorerids.ridges(ridgenumbers(scali)).result.intensity';
                    peakshere(scali).CompoundNames = tempstorerids.ridges(ridgenumbers(scali)).result.names;
                    peakshere(scali).quantifiable = tempstorerids.ridges(ridgenumbers(scali)).result.quanvec;
                  else
                    peakshere(scali).Ridges = [];
                    peakshere(scali).RowInds = [];
                    peakshere(scali).RidgeIntensities = [];
                    peakshere(scali).CompoundNames = [];
                    peakshere(scali).quantifiable = [];
                  end
                end
                reg = matchPPMs(currentTrackingRegion,ppm);
                ind = reg(1):reg(2);
                mathere = matrix(:,ind);
                ppmhere = ppm(ind);
                save(['Sample-',num2str(currentTrackingRegion(1)),'-',num2str(currentTrackingRegion(2)),'ppm.mat'],'Sample');
%                 fig = stackSpectra_paintRidges_3return(mathere,ppmhere,thisExp.horzshift,0.01,plotTitle,peakshere,10);
%                 saveas(fig,strcat(cd(),'/',plotTitle,'.scatter.experiment.manual.fig'));
%                 close(fig);
                
    end
    cd(startpath)
    return
end