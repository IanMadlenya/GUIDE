bondtreegui <-
function(){
    
    my.redraw <- function(panel)
    {
      rp.tkrreplot(panel, tkrp)
      panel                                                                       
    }
    
    my.draw <- function(panel){
      
      FV=as.numeric(panel$FV)
      r0=as.numeric(panel$r0)
      u=as.numeric(panel$u)
      d=as.numeric(panel$d)
      q=as.numeric(panel$q)
      coupon=as.numeric(panel$coupon)
      bondmaturity=as.numeric(panel$bondmaturity)
      nsteps=as.numeric(panel$bondmaturity)
      #ratesteps=as.numeric(panel$ratesteps)
      ratesteps=bondmaturity
      
      
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
      
 
      
      bondtree <- function(FV,coupon,r0,u,d,q,bondmaturity,optional){
        
        nsteps = bondmaturity
        
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
          forward = 0
          future = 0
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
          forward = optional[10]
          future = optional[11]
        }
        
        
        
        optional=c(timepoints,gap,margin,nrows,ncols,dt,startrow,startcol,lastrow)
        #optional=c(nsteps,timepoints,gap,margin,nrows,ncols,dt,startrow,startcol,lastrow)
        
        ratesteps <- bondmaturity
        Rates <- ratetree(r0,u,d,q,ratesteps,optional)
        
        #print(Rates)
        
        #redefine for bond
        
        
        #optional=c(timepoints,gap,margin,nrows,ncols,dt,startrow,startcol,lastrow,forward,future)
        
        
        
        P = matrix(data = NA, nrow = nrows, ncol = ncols)
        thisstep=nsteps
        
        for (col in seq(from = ncols-nsteps-margin-thisstep, to=ncols-nsteps-margin+thisstep, by = 2)) {     
          P[lastrow, col] = FV+FV*coupon/100
          thisstep=thisstep-1
        }
        
        thisstep=nsteps-1 
        for (row in seq(from = (lastrow - (gap+1)), to = startrow, by = -(gap+1))) {
          
          
          
          for (col in seq(from = ncols-nsteps-margin-thisstep, to=ncols-nsteps-margin+thisstep, by = 2)) {
            
            if (forward==0 && future==0){
              P[row, col] = FV*coupon/100 +  (P[row + (gap+1), col + 1] * q + P[row + (gap+1), col - 1] * (1 - q))/(1+Rates[row, col]/100)
            }
            else if(future !=0 ){
              if (thisstep < future){
                P[row, col] = P[row + (gap+1), col + 1] * q + P[row + (gap+1), col - 1] * (1 - q)
              }
              else if(thisstep == future){
                P[row, col] = (P[row + (gap+1), col + 1] * q + P[row + (gap+1), col - 1] * (1 - q))/(1+Rates[row, col]/100)
              }
              else{
                P[row, col] = FV*coupon/100 +(P[row + (gap+1), col + 1] * q + P[row + (gap+1), col - 1] * (1 - q))/(1+Rates[row, col]/100)
              }
            }
            else{
              if (thisstep <= forward){
                P[row, col] = (P[row + (gap+1), col + 1] * q + P[row + (gap+1), col - 1] * (1 - q))/(1+Rates[row, col]/100)
              }
              else{
                P[row, col] = FV*coupon/100 +(P[row + (gap+1), col + 1] * q + P[row + (gap+1), col - 1] * (1 - q))/(1+Rates[row, col]/100)
              }
            }
            
            
          }
          thisstep=thisstep-1
        }
        #P=round(P,2)
        P
      }
      #bondtree(FV=100,coupon=0,r0=5,u=1.1,d=0.9,q=0.5,bondmaturity=4)
      
       
      R = ratetree(r0,u,d,q,ratesteps)

      P = bondtree(FV,coupon,r0,u,d,q,bondmaturity)
      
      
      
      
      
      # set graphs options
      if (nsteps>= 2){
        cex=0.9
      }
      else{
        cex=1
      }
      
      
      
      if (panel$plot == "Bond Tree"){
        topaste = "Bond" 
        M = P 
        nrows = dim(P)[1]
        ncols = dim(P)[2]
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
          text(i, j, round(M[i,j],2),cex=cex) # ,col="red")  
        }
      }
      title(main = paste(floor(nrows/2),"Step ", topaste, " Tree"))
      panel
    }   
    
    
    
    
    my.panel <- rp.control(title = "Bond Tree")
    
    rp.textentry(panel=my.panel,variable=FV,action=my.redraw,    title="Face value      ",initval=100)
    rp.textentry(panel=my.panel,variable=r0,action=my.redraw,    title="Rate (initial)   ",initval=5.0)
    rp.textentry(panel=my.panel,variable=coupon,action=my.redraw,title="Coupon          ",initval=0.0)
    rp.textentry(panel=my.panel,variable=u,action=my.redraw,     title="up per step     ",initval=1.1)
    rp.textentry(panel=my.panel,variable=d,action=my.redraw,     title="down per step",initval=0.9)
    rp.textentry(panel=my.panel,variable=q,action=my.redraw,     title="q per step       ",initval=0.5)
    #rp.doublebutton(panel = my.panel, showvalue=TRUE, variable= ratesteps, step = 1, range = c(1, 16),initval=10,
    #                title = "Rate tree steps", action = my.redraw)
    rp.doublebutton(panel = my.panel, showvalue=TRUE, variable= bondmaturity, step = 1, range = c(1, 15),initval=10,
                    title = "Bond Maturity", action = my.redraw)
    rp.radiogroup(panel = my.panel, variable= plot,
                  vals = c("Bond Tree","Rate Tree"), 
                  pos="right", action = my.redraw, title = "Plot Type")
    rp.tkrplot(panel=my.panel , name=tkrp, plotfun=my.draw, pos="right",hscale=2,vscale=1.9)
    #rp.do(my.panel, my.draw)
  }
