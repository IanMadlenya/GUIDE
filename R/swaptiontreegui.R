swaptiontreegui <-
function(){
    
    my.draw <- function(panel){
      
      FV=as.numeric(panel$FV)
      strike=as.numeric(panel$strike)
      r0=as.numeric(panel$r0)
      u=as.numeric(panel$u)
      d=as.numeric(panel$d)
      q=as.numeric(panel$q)
      fixedrate = as.numeric(panel$fixedrate)
      swapmaturity=as.numeric(panel$swapmaturity)
      optmaturity=as.numeric(panel$optmaturity)
      nsteps=as.numeric(panel$swapmaturity)
      ratesteps=as.numeric(panel$swapmaturity)
      
      ratetree <- function(r0,u,d,q,ratesteps,optional){
        
        if(missing(optional)) {
          timepoints = ratesteps + 1
          gap = 1 # gap between rows
          margin = 0
          nrows = (gap+1) * ratesteps + 1 + 2 * margin
          ncols = 2 * (ratesteps) + 1 + 2 * margin
          dt = 1
          startrow = margin + 1
          startcol = margin + 1
          lastrow = nrows - margin
        }
        
        #optional=c(timepoints,gap,margin,nrows,ncols,dt,startrow,startcol,lastrow)
        
        else{
          timepoints=optional[1]
          gap=optional[2]
          margin=optional[3]
          nrows=optional[4]
          ncols=optional[5]
          dt=optional[6]
          startrow=optional[7]
          startcol=optional[8]
          lastrow=optional[9]
        }
        
        Rates = matrix(data = NA, nrow = nrows, ncol = ncols)
        Rates[startrow, ratesteps + margin + 1] = r0
        
        thisstep= 0
        
        for (row in seq(from = startrow + gap+1, to = nrows - margin, by = gap+1)) {
          thisstep = thisstep+1
          for (col in seq(from = ncols-ratesteps-margin-thisstep, to=ncols-ratesteps-margin+thisstep, by = 2)) {
            if (col <= ceiling(ncols/2)) {
              Rates[row, col] = Rates[row - (gap+1), col + 1] * d
            }
            else {
              Rates[row, col] = Rates[row - (gap+1), col - 1] * u
            }
          }
        }
        #Rates=round(Rates,2)
        Rates
      }
      #ratetree(r0=6,u=1.25,d=0.9,q=0.5,ratesteps=4)
      
      
      
      R = ratetree(r0,u,d,q,ratesteps)
      
      swaptree <- function(FV,fixedrate,swapmaturity,r0,u,d,q,optional){
        
        nsteps = swapmaturity
        if(missing(optional)) {
          timepoints = nsteps + 1
          gap = 1 # gap between rows
          margin = 0
          nrows = (gap+1) * nsteps + 1 + 2 * margin
          ncols = 2 * (nsteps) + 1 + 2 * margin
          dt = 1
          startrow = margin + 1
          startcol = margin + 1
          lastrow = nrows - margin
        }
        
        #optional=c(timepoints,gap,margin,nrows,ncols,dt,startrow,startcol,lastrow)
        
        else{
          timepoints=optional[1]
          gap=optional[2]
          margin=optional[3]
          nrows=optional[4]
          ncols=optional[5]
          dt=optional[6]
          startrow=optional[7]
          startcol=optional[8]
          lastrow=optional[9]
        }
        
        
        optional=c(timepoints,gap,margin,nrows,ncols,dt,startrow,startcol,lastrow)
        
        ratesteps <- swapmaturity
        Rates <- ratetree(r0,u,d,q,ratesteps,optional)
        #P <- bondtree(FV,coupon,r0,u,d,q,bondmaturity,optional)
        
        
        
        O = matrix(data = NA, nrow = nrows, ncol = ncols)
        
        # final nodes
        thisstep=nsteps   
        
        for (col in seq(from = ncols-nsteps-margin-thisstep, to=ncols-nsteps-margin+thisstep, by = 2)) {
          
          O[lastrow, col] = (Rates[lastrow, col] - fixedrate)/100 / (1+Rates[lastrow, col]/100)
          
        }
        
        # intermediate nodes
        thisstep=nsteps-1       
        for (row in seq(from = (lastrow - (gap+1)), to = startrow, by = -(gap+1))) {
          
          for (col in seq(from = ncols-nsteps-margin-thisstep, to=ncols-nsteps-margin+thisstep, by = 2)) {
            
            O[row, col] = ((Rates[row, col] - fixedrate)/100 + O[row + gap+1, col + 1] * q + O[row + gap+1, col - 1] * (1 - q)) /(1+Rates[row, col]/100)
            
          }
          thisstep=thisstep-1
        }
        
        
        
        
        swapvalue= (O[startrow+gap+1,ceiling(ncols/2)-1]*(1-q) + O[startrow+gap+1,ceiling(ncols/2)+1]*q) *FV / (1+ Rates[startrow,ceiling(ncols/2)]/100)
        swapvalue=round(swapvalue,2)
        #O=round(O,4)
        
        ans=list(swapvalue,O)
        
        
        ans
      }
      
      swaptiontree <- function(FV,strike,fixedrate,swapmaturity,optmaturity,r0,u,d,q){
        
        nsteps = swapmaturity
        timepoints = nsteps + 1
        gap = 1 # gap between rows
        margin = 0
        nrows = (gap+1) * nsteps + 1 + 2 * margin
        ncols = 2 * (nsteps) + 1 + 2 * margin
        dt = 1
        startrow = margin + 1
        startcol = margin + 1
        lastrow = nrows - margin
        
        optional=c(timepoints,gap,margin,nrows,ncols,dt,startrow,startcol,lastrow)
        ratesteps=swapmaturity
        
        Rates <- ratetree(r0,u,d,q,ratesteps,optional)
        Rates2 = swaptree(FV,fixedrate,swapmaturity,r0,u,d,q,optional)[[2]]
        
        # extract relevant portion of rates tree
        Pbegincol=swapmaturity-optmaturity+1
        Pendcol=2*swapmaturity + 1 - (swapmaturity - optmaturity)
        
        #P = P[1:nrows,Pbegincol:Pendcol]
        Rates = Rates[1:nrows,Pbegincol:Pendcol]
        Rates2 = Rates2[1:nrows,Pbegincol:Pendcol]
        
        
        #redefine for option tree
        nsteps = optmaturity
        timepoints = nsteps + 1
        gap = 1 # gap between rows
        margin = margin
        nrows = (gap+1) * nsteps + 1 + 2 * margin
        ncols = 2 * (nsteps) + 1 + 2 * margin
        dt = 1
        startrow = margin + 1
        startcol = margin + 1
        lastrow = nrows - margin
        
        
        O = matrix(data = NA, nrow = nrows, ncol = ncols)
        
        # final nodes
        thisstep=nsteps   
        
        for (col in seq(from = ncols-nsteps-margin-thisstep, to=ncols-nsteps-margin+thisstep, by = 2)) {
          
          O[lastrow, col] = max(Rates2[lastrow, col], strike)
          
        }
        
        # intermediate nodes
        thisstep=nsteps-1       
        for (row in seq(from = (lastrow - (gap+1)), to = startrow, by = -(gap+1))) {
          
          for (col in seq(from = ncols-nsteps-margin-thisstep, to=ncols-nsteps-margin+thisstep, by = 2)) {
            
            O[row, col] = (O[row + gap+1, col + 1] * q + O[row + gap+1, col - 1] * (1 - q)) /(1+Rates[row, col]/100)
            
          }
          thisstep=thisstep-1
        }
        
        
        
        swaptionvalue= O[startrow,ceiling(ncols/2)]*FV
        swaptionvalue=round(swaptionvalue,2)
        
        ans = list(swaptionvalue,O)
        
        ans
        
        
        
      }
      
      
      O= swaptiontree(FV,strike,fixedrate,swapmaturity,optmaturity,r0,u,d,q)[[2]]
      
      val = swaptiontree(FV,strike,fixedrate,swapmaturity,optmaturity,r0,u,d,q)[[1]]
      
      
      
      S = swaptree(FV,fixedrate,swapmaturity,r0,u,d,q)[[2]]
      
      
      # set graphs options
      if (nsteps>= 2){
        cex=0.9
      }
      else{
        cex=1
      }
      
      
      
      if (panel$plot == "Swaption Tree"){
        topaste = "Swaption" 
        M = O 
        nrows = dim(O)[1]
        ncols = dim(O)[2]
      }
      else if (panel$plot == "Swap Tree"){
        topaste = "Swap" 
        M = S 
        nrows = dim(S)[1]
        ncols = dim(S)[2]
      }
      else{
        topaste = "Rate"
        M = R  
        nrows = dim(R)[1]
        ncols = dim(R)[2]
      }
      
      
#       if (length(dev.list()) == 0) 
#         dev.new()
      plot(1:nrows, 1:ncols, type="n",ylab="",xlab="", 
           axes=FALSE, frame = FALSE)
      
      for (i in 1:nrows){
        for (j in 1:ncols){
          text(i, j, round(M[i,j],3),cex=cex) # ,col="red")  
        }
      }
      title(main = paste(floor(nrows/2),"Step ", topaste, " Tree. Swaption value = ", val))
      panel
    }   
    
    my.redraw <- function(panel) #not needed bcos we are not using tkr plot
    {
      rp.tkrreplot(panel, my.tkrplot)
      panel                                                                       
    }   
    
    
    my.panel <- rp.control(title = "Swaption Tree")
    
    rp.textentry(panel=my.panel,variable=FV,action=my.redraw,title="Face value       ",initval=100)
    rp.textentry(panel=my.panel,variable=strike,action=my.redraw,title="strike               ",initval=0)
    rp.textentry(panel=my.panel,variable=r0,action=my.redraw,title="Rate (initial)    ",initval=5.0)
    rp.textentry(panel=my.panel,variable=u,action=my.redraw,title="up per step     ",initval=1.1)
    rp.textentry(panel=my.panel,variable=d,action=my.redraw,title="down per step",initval=0.9)
    rp.textentry(panel=my.panel,variable=q,action=my.redraw,title="q per step       ",initval=0.5)
    rp.textentry(panel=my.panel,variable=fixedrate,action=my.redraw,title="Fixed Rate      ",initval=4.5)
    rp.doublebutton(panel = my.panel, showvalue=TRUE, variable= swapmaturity, step = 1, range = c(1, 15),initval=10,
                    title = "Swap Maturity", action = my.redraw)
    rp.doublebutton(panel = my.panel, showvalue=TRUE, variable= optmaturity, step = 1, range = c(1, 15),initval=5,
                    title = "Option Maturity", action = my.redraw)
    rp.radiogroup(panel = my.panel, variable= plot,
                  vals = c("Swaption Tree", "Swap Tree","Rate Tree"), 
                  action = my.redraw, title = "Plot Type")
    rp.tkrplot(panel=my.panel, name=my.tkrplot, plotfun=my.draw, hscale=3, vscale=1.5)
    #rp.do(my.panel, my.draw)
  }
