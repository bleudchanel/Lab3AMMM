/*********************************************
 * OPL 12.8.0.0 Model
 * Author: BleuDChan
 * Creation Date: Oct 15, 2018 at 10:35:06 AM
 *********************************************/

int nTasks=...;
int nThreads=...;
int nCPUs=...;
int nCores=...;

range T=1..nTasks;
range C=1..nCPUs;
range H=1..nThreads;
range K=1..nCores;

float rc[c in C]=...;
float rh[h in H]=...;

int CK[c in C, k in K]=...;
int TH[t in T, h in H]=...;

int nH[t in T];
int nK[c in C];
int depCPU[k in K];
int depTask[h in H];
float sumLoad[c in C];

dvar boolean x_tc[t in T, c in C];
dvar boolean x_hk[h in H, k in K];
dvar float+ z;

execute {
	
	var totalLoad=0;
	
	for (var t=1;t<=nThreads;t++)
		totalLoad += rh[t];
		
	writeln("Total load " + totalLoad);
	
	for (var t=1;t<=nTasks;t++)
		for(var h=1;h<=nThreads;h++)
			nH[t] += TH[t][h];
	
	for (var t=1;t<=nTasks;t++)
		writeln("nH[" + t + "] :" + nH[t]);	
			
			
	for (var c=1;c<=nCPUs;c++)
		for(var k=1;k<=nCores;k++)
			nK[c] += CK[c][k];
	
	for (var c=1;c<=nCPUs;c++)
		writeln("nK["+ c +"] :" + nK[c]);
			
	
}

//Objective
minimize z;

subject to {

//Constraint 1
forall(h in H)
  sum(k in K) x_hk[h,k] == 1;
  
//Constraint 2
forall(t in T, c in C)
  sum(h in H : TH[t][h] == 1) sum(k in K : CK[c][k] == 1) x_hk[h,k] == nH[t] * x_tc[t][c];
  
//Constraint 3
forall(c in C, k in K : CK[c][k] == 1)
  sum(h in H) rh[h]* x_hk[h,k] <= rc[c];


//Constraint 4
forall(c in C)
  z >= (1/(nK[c]*rc[c])) * sum(h in H) sum(k in K : CK[c][k] == 1) rh[h]* x_hk[h,k];
  
}

execute {
	
	writeln("--------Threads----------")
	for(var t=1;t<=nTasks;t++){
		for(var h=1;h<=nThreads;h++){
			if(TH[t][h] == 1){
				depTask[h] = t;
				writeln("Thread " + h + " belongs to task " + t)		
			}
					
  		}
	}  				
	writeln("------------------")
	writeln("---------Cores-----------")
	for(var c=1;c<=nCPUs;c++)
	{
		for(var k=1;k<=nCores;k++){
			if(CK[c][k] == 1){
				depCPU[k] = c;
				writeln("Core " + k + " belongs to Computer " + c)				
			}	
		}	
	}
	
	writeln("------------------")
	for (var h=1;h<=nThreads;h++){
		var load=0;
		for (var k=1;k<=nCores;k++){
			if (x_hk[h][k] == 1){
				load += rh[h] * x_hk[h][k];
				writeln(rh[h] + " load from thread " + h + " from task "+ depTask[h] +" -> into core " + k + " from CPU " + depCPU[k] + " cap: " + rc[depCPU[k]]);
				sumLoad[depCPU[k]] += rh[h];
			}				
		}
			 
		//load = load/currentCapacity;	
		//writeln("Core " + c + " loaded at "+ load + "%");	
		writeln("---------------------")
	}
	writeln("------------------")
	
	for (var c=1;c<=nCPUs;c++){
		var currentCapacity = 0;
		currentCapacity = rc[c] * nK[c];
		writeln("CPU " + c + " : " + sumLoad[c] +"/" + currentCapacity + " = " + sumLoad[c]/currentCapacity + "%");
	}
}


























 