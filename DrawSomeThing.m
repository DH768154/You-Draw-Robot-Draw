function DrawSomeThing

r = 2/3;
ss = get(groot,'screensize');
sr = ss(4)/ss(3);
lim = [1,r]/max([1,r]);


data = [];

f = figure('Name', 'Continous Tracking', 'NumberTitle', 'off',...
    'ToolBar','none','MenuBar','none','Resize','off');
ax = axes('Parent', f,'Units','normalized','Position',[0.05,0.05,0.85,0.9]);
P = plot(NaN, NaN, '-','Color',[0 0.4470 0.7410],'LineWidth',4);
hold on; grid on
axis equal
xlim([0 lim(1)]); ylim([0 lim(2)]);
xticks(linspace(0,lim(1),11)); yticks(linspace(0,lim(2),11));


title('Left Click: Start/Break    |    Right Click: Clear','Color','r','FontWeight','bold')
WH = [lim(1)+0.05,lim(2)/sr];
WH = WH/max(WH)*0.8;
set(f,'Unit','normalized','Position',[(1-WH)/2,WH])

clearBtn = uicontrol('Parent',f,'Units','normalized',...
    'FontUnits','normalized','String','Clear',...
    'Style','pushbutton','Position',[0.915,0.55,0.07,0.05],...
    'BackgroundColor',[0.85,0.85,0.85],'ForegroundColor',[0,0,0],...
    'FontSize',0.55,'FontName','Calibri','FontWeight','bold',...
    'HorizontalAlignment','center');
expBtn = copyobj(clearBtn,f);
expBtn.Position = [0.915,0.495,0.07,0.05];
expBtn.String = 'export';

record = false;

set(f, 'WindowButtonDownFcn', @(obj, ~) startstop(obj));
set(f, 'WindowButtonMotionFcn', @(obj, ~) mouseMove(obj));
set(clearBtn,'Callback',@(obj, ~)cleardata(obj));
set(expBtn,'Callback',@(obj, ~)expdata(obj));

%% Mouse Move
    function mouseMove(~)
        if record
            datac = ax.CurrentPoint;
            data = [data,datac(1,1:2)'];
            P.XData = data(1,:);
            P.YData = data(2,:);
            drawnow;
        end
    end

%% Mouse Click
    function startstop(hobj)
        LR = hobj.SelectionType;

        cdata = ax.CurrentPoint(1,1:2)';
        if any(cdata<0) || any(cdata>1)
            return
        end

        if strcmpi(LR,'alt')
            cleardata;
        else
            record = ~record;
            if ~record
                data = [data, NaN(2,1)];
            end
        end
    end

%% Clear
    function cleardata(~)
        data = [];
        P.XData = NaN;
        P.YData = NaN;
        drawnow;
    end

%% Export
    function expdata(~)
        dataout = data(:,1:end-1);
        ind = any([dataout<0; dataout>lim(:)]);
        dataout(:,ind) = NaN;
        assignin('base', 'TrackDataC', dataout);
        UR5_Draw(dataout)
    end

end