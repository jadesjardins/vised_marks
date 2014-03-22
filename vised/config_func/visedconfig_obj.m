classdef visedconfig_obj
    
    properties

        %vised options
        pop_gui='on'
        data_type=''
        chan_index=[]
        event_type={}

        winrej_marks_labels={}
        quick_evtmk=''
        quick_evtrm='off'
        quick_chanflag='off'
        
        
        chan_marks_struct=[]
        time_marks_struct=[]
        marks_y_loc=[]
        inter_mark_int=[]
        inter_tag_int=[]
        marks_col_int=[];
        marks_col_alpha=[];


        %eegplot options
        srate=[]
        spacing=[]
        eloc_file=''
        limits=[]
        freqlimits=[]
        winlength=[]
        dispchans=[]
        title=''
        xgrid='off'
        ygrid='off'
        ploteventdur='off'
        data2=''
        command=''
        butlabel=''
        winrej=[]
        color=''
        wincolor=[]
        colmodif={}
        tmp_events=[]
        submean='on'
        position=[]
        tag='vef'
        children=[]
        scale='on'
        mocap=''
        
        selectcommand={''}
        altselectcommand={''}
        extselectcommand={''}
        keyselectcommand={''}

        trialstag=[]
        datastd=[]
        normed=[]
        envelope=[]
        chaninfo=[]

    end    
end