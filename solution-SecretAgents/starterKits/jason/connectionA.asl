/* ----- INITIAL BELIEFS AND RULES ------  */
position_agent(0,0).
agent_moves(randomly_moves).
request_block(false).
reaching_edge(false).
mindistance(10).

reached_goal(A, false):- A = connectionA1.
reached_goal(A, false):- A = connectionA2.
reached_goal(A, false):- A = connectionA3.
reached_goal(A, false):- A = connectionA4.
reached_goal(A, false):- A = connectionA5.

found_goal(A, false) :- A = connectionA1.
found_goal(A, false) :- A = connectionA2.
found_goal(A, false) :- A = connectionA3.
found_goal(A, false) :- A = connectionA4.
found_goal(A, false) :- A = connectionA5.

found_dispenser(A, false):- A = connectionA1.
found_dispenser(A, false):- A = connectionA2.
found_dispenser(A, false):- A = connectionA3.
found_dispenser(A, false):- A = connectionA4.
found_dispenser(A, false):- A = connectionA5.

blockattached(A, false):- A = connectionA1.
blockattached(A, false):- A = connectionA2.
blockattached(A, false):- A = connectionA3.
blockattached(A, false):- A = connectionA4.
blockattached(A, false):- A = connectionA5.

goal_found(A,0,0):- A = connectionA1.
goal_found(A,0,0):- A = connectionA2.
goal_found(A,0,0):- A = connectionA3.
goal_found(A,0,0):- A = connectionA4.
goal_found(A,0,0):- A = connectionA5.

// near_obstacle(A,0,0):- A = connectionA1.
// near_obstacle(A,0,0):- A = connectionA2.
// near_obstacle(A,0,0):- A = connectionA3.
// near_obstacle(A,0,0):- A = connectionA4.
// near_obstacle(A,0,0):- A = connectionA5.

// nearest_goal(A,0,0):- A = connectionA1.
// nearest_goal(A,0,0):- A = connectionA2.
// nearest_goal(A,0,0):- A = connectionA3.
// nearest_goal(A,0,0):- A = connectionA4.
// nearest_goal(A,0,0):- A = connectionA5.


random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) | (RandomNumber <= 0.5 & .nth(1,DirList,Dir)) | (RandomNumber <= 0.75 & .nth(2,DirList,Dir)) | (.nth(3,DirList,Dir)).

!start.                

/* ------ PLANS ------- */

+!start : true <- 
	.print(" ----- Contest Has Started. ------ ").
	
+step(X)[entity(A), source(B)]: taskList(N,D,B) <-
	-taskList(N,D,B);
	.print(" -- *** UPDATED TASK LIST *** -- ", X).

// +step(X)[entity(A), source(B)]: true <-
// 	!obstacles_list[entity(A), source(B)].

// +step(X)[entity(A), source(B)]: agent_moves(search_goal) & not(found_goal(A, true)) <-
// 	!find_nearest_goal[entity(A), source(B)];
// 	?nearest_goal(A,GbX,GbY);
// 	.print(" --- ONE GOAL : ", A, GbX, GbY).

// ---------- ACTION WHEN AGENT HAS TO MOVE RANDOMLY ----------
+actionID(X)[entity(A), source(B)] : agent_moves(randomly_moves) & not(found_goal(A,true)) <- 
	.print("----------- ACTION ID -------- : ", X);
	// .list_rules;
	.print(" -- RANDOMLY MOVES -- ");
	?blockattached(Agx, Flag);
	if ((Flag == true) & (Agx == A)){
		!make_map[entity(A), source(B)];
		-+agent_moves(search_goal);
	}else{
		!make_map[entity(A), source(B)];
	}.
	

// ----------- ACTION TO SEARCH THE DISPENSER -----------------
+actionID(X)[entity(A), source(B)] : agent_moves(randomly_moves) & found_dispenser(A, false) & task_started(true) <-
	.print("----------- ACTION ID -------- : ", X);
	.print(" --- SEARCHING A DISPENSER --- ");
	!move_random[entity(A), source(B)].

// ----------- ACTION WHEN AGENT HAS TO MOVE TO DISPENSER ----------- 
+actionID(X)[entity(A),source(B)]:  move_to_dispenser(A, Dx, Dy) & agent_moves(to_dispenser) & not(lastActionResult(failed_path)) <-
	.print("----------- ACTION ID -------- : ", X);
	.print(" -- MOVING TO DISPENSER -- ");
	!move_to(Dx, Dy, dispenser)[entity(A),source(B)].


// ----------- ACTION WHEN LAST ACTION IS A FAILED PATH -------------
+actionID(X)[entity(A),source(B)]: lastActionResult(failed_path) & position_agent(AgX, AgY) & lastActionParams(Params) <-
	.print("----------- ACTION ID -------- : ", X);
	.member(D, Params);
	.print("-- OBSTACLE IN PATH -- ");
	.print(" -- LAST MOVED -- : ",D);
	!move_away_from_obstacle(D, AgX, AgY)[entity(A),source(B)].


// ----------- ACTION WHEN LAST ACTION IS FAILED FORBIDDEN ------------
+actionID(X): lastActionResult(failed_forbidden) & position_agent(AgX, AgY) & lastActionParams(Params) <-
	.print("SOMETHING LAST ACTION :",result);
	.print("EDGE REACHED");
	.member(D, Params);
	?position_agent(AgX, AgY);
	-reaching_edge(false);
	+reaching_edge(true);
	!check_edge(D, Agx, AgY);
	.print(" ------- MOVED AWAY FROM EDGE ------- ").


// ------------ ACTION WHEN AGENT HAS REQUESTED A BLOCK AND NOW WANTS TO ATTACH TO THE BLOCK ---------- 
+actionID(X)[entity(A),source(B)]:  agent_moves(attachncomplete) & request_block(true) & not(lastActionResult(failed_path)) & attach_cordinates(AtX, AtY) <-
	.print("----------- ACTION ID -------- ", X);
	.print(" --- REQUESTED AND NOW ATTACH BLOCK --- ");
	?attach_cordinates(AtX, AtY);
	if((AtX == -1) & (AtY == 0)){
		.print(" ------ ATTACHED FROM WEST ------ ");
		attach(w);
		-agent_moves(attachncomplete);
		-blockattached(A ,Dir, false);
		+blockattached(A, Dir, true);
		+agent_moves(search_goal);
	}
	elif((AtX == 1) & (AtY == 0)){
		.print(" - ATTACHED FROM EAST - ");
		attach(e);
		-agent_moves(attachncomplete);
		-blockattached(A ,false);
		+blockattached(A, true);
		+agent_moves(search_goal);
	}
	elif((AtX == 0) & (AtY == -1)){
		.print(" - ATTACHED FROM NORTH - ");
		attach(n);
		-agent_moves(attachncomplete);
		-blockattached(A ,false);
		+blockattached(A, true);
		+agent_moves(search_goal);
	}
	elif((AtX == 0) & (AtY == 1)){
		.print(" - ATTACHED FROM SOUTH - ");
		attach(s);
		-agent_moves(attachncomplete);
		-blockattached(A ,false);
		+blockattached(A, true);
		+agent_moves(search_goal);
	}.


// ----------- ACTION WHEN AGENT MOVES TO SEARCH GOAL -------------
+actionID(X)[entity(A), source(B)]: agent_moves(search_goal) <-
	.print("----------- ACTION ID -------- : ", X);
	.print(" --- SEARCHING FOR A GOAL --- ");
	!move_random[entity(A), source(B)].

// ---------- ACTION WHEN AGENT FINDS A GOAL AND MOVES TOWARDS IT --------
+actionID(X)[entity(A),source(B)]:  found_goal(A,true) & goal_found(A,Gx,Gy) & blockattached(A, true) & thing(Bx, By, block, Details)[entity(A),source(B)] <-
	.print(" --- MOVING TOWARDS THE GOAL -- : AGENT :", A, " , (",Gx,Gy,")");
	// ---------- LOGIC TO ROTATE A BLOCK -----------
	// --- CHECK THE DIRECTION OF ATTACHED BLOCK AND ROTATE IT FIRST TO ATTACH FROM NORTH --- //
	.print(" --- ROTATING FOR GOAL --- ");
	if((Bx == 0) & (By == 1)){
		!move_to(Gx, Gy, goal)[entity(A),source(B)];
	}elif((Bx == 0) & (By == -1)){
		rotate(cw);
	}elif((Bx == 1) & (By == 0)){
		rotate(ccw);
	}elif((Bx == -1) & (By == 0)){
		rotate(cw);
	}.
// ---------------- TRAVERSE THE LOCAL MAP RANDOMLY --------------
+!make_map[entity(A), source(B)]:  agent_moves(randomly_moves) <-
	!move_random[entity(A), source(B)];
	.print(" -- Agent Maps The World. -- ").

// ---------- MOVE IN A PARTICULAR DIRECTION AND TRACE EDGES ----------
+!check_edge(D, EdgeX, EdgeY): reaching_edge(true) <-
	.print(" -- LAST ACTION PARAMETER EDGE -- ", D);
	if(D == n){
		-+position_agent(EdgeX, (EdgeY+1));
		move(s);
		// .print(" -- MOVES SOUTH AWAY FROM EDGE. -- ");
	}elif(D == e){
		-+position_agent((EdgeX+1),EdgeY);
		move(w);
		// .print(" -- MOVES WEST AWAY FROM EDGE. -- ");
	}elif(D == s){
		-+position_agent(EdgeX,(EdgeY-1));
		move(n); 
		// .print(" -- MOVES NORTH AWAY FROM EDGE. -- ");
	}elif(D == w){
		-+position_agent((EdgeX-1),EdgeY);
		move(e);
		// .print(" -- MOVES EAST AWAY FROM EDGE. -- ");
	}.


// ------------- CODE TO MOVE AGENT RANDOMLY ON MAP -------------
+!move_random[entity(A), source(B)] : .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir) & position_agent(X,Y) & (agent_moves(randomly_moves)|agent_moves(search_goal))<-
	// terraintype(X,Y);
	if(Dir == n){
		-+position_agent(X,(Y-1));
	}elif(Dir == e){
		-+position_agent((X+1),Y);
	}elif(Dir == s){
		-+position_agent(X,(Y+1)); 
	}elif(Dir == w){
		-+position_agent((X-1),Y);
	};
	move(Dir);
	.print("-- Agent Moves Randomly -- : ",Dir).

// ------------- MOVING TO ANY PARTICULAR POINT IN THE GRAPH --------------
+!move_to(Dx, Dy, Type)[entity(A),source(B)]: position_agent(AgX, AgY) & (agent_moves(to_dispenser)|found_goal(A, true)| agent_moves(found_goal)) <-
	.print(" -- REACHING LOCATION -- : ", Dx, " , ", Dy);
	.print(" -- AGENT LOCATION -- : ", AgX, " , ", AgY);
	if(((Dx == -1) & (Dy == 0))|((Dx == 1) & (Dy == 0))|((Dx == 0) & (Dy == -1))|((Dx == 0) & (Dy == 1))){ 
		// ------ CODE TO REQUEST BLOCK AND AGENT MOVES TO DISPENSER CHANGES TO TASK PERFORM. ----
		if(Type == dispenser){
			// ----- REQUESTING BLOCK FROM DISPENSER -----
			?position_agent(AgX, AgY);
			.print(" -- THING CORDINATES -- : ", Dx , " , ", Dy);
			.print(" -- NOW AGENT WILL REQUEST FOR BLOCK -- ");
			if(((Dx == -1) & (Dy == 0))){
				.print(" - REQUESTS FROM THE WEST -");
				request(w);
				-request_block(false);
				+request_block(true);
				-move_to_dispenser(A, Dx, Dy);
				-agent_moves(to_dispenser);
				+agent_moves(attachncomplete);
				+attach_cordinates(Dx, Dy);
			}elif(((Dx == 1) & (Dy == 0))){
				.print(" - REQUESTS FROM THE EAST - ");
				request(e);
				-request_block(false);
				+request_block(true);
				-move_to_dispenser(A, Dx, Dy);
				-agent_moves(to_dispenser);
				+agent_moves(attachncomplete);
				+attach_cordinates(Dx, Dy);
			}elif(((Dx == 0) & (Dy == -1))){
				.print(" - REQUESTS FROM THE NORTH -");
				request(n);
				-request_block(false);
				+request_block(true);
				-move_to_dispenser(A, Dx, Dy);
				-agent_moves(to_dispenser);
				+agent_moves(attachncomplete);
				+attach_cordinates(Dx, Dy);
			}elif(((Dx == 0) & (Dy == 1))){
				.print(" - REQUESTS FROM THE SOUTH - ");
				request(s);
				-request_block(false);
				+request_block(true);
				-move_to_dispenser(A, Dx, Dy);
				-agent_moves(to_dispenser);
				+agent_moves(attachncomplete);
				+attach_cordinates(Dx, Dy);
			};
		}
		else{
			.print(" ================= REACHED GOAL... ================== : ", A);
			+reached_goal(A, true);
		};
		
	}elif((( Dx > 0 ) & (Dy == 0))|( Dx > 0 )){
		move(e);
		?lastActionResult(Result);
		.print("LAST ACTION RESULT : ",Result);
		if(Result == success){
			-+position_agent(AgX+1, AgY);
			.print("Move East");
			if(Type == dispenser){
				?thing(NDx, NDy, Type, Details)[entity(A), source(B)];
				+move_to_dispenser(A, NDx-1, NDy);
				.print(" -- UPDATED DISPENSER LOCATION -- : ", NDx-1, " , ", NDy);
			}elif(Type == goal){
				?goal_found(A,Gx, Gy);
				-+goal_found(A,Gx+1, Gy);
				.print(" -- UPDATED GOAL LOCATION -- : ", Gx+1, " , ", Gy);
			};
		};

	}elif(((Dx < 0) & (Dy == 0))|(Dx < 0)){
		move(w);
		?lastActionResult(Result);
		if(Result==success){
			.print(Result);
			.print("Move West");
			-+position_agent(AgX-1, AgY);
			if(Type == dispenser){
				?thing(NDx, NDy, Type, Details)[entity(A), source(B)];
				+move_to_dispenser(A, NDx+1, NDy);
				.print(" -- UPDATED DISPENSER LOCATION -- :", NDx+1, " , ", NDy);
			}elif(Type == goal){
					?goal_found(A, Gx, Gy);
					-+goal_found(A, Gx-1, Gy);	
					.print(" -- UPDATED GOAL LOCATION -- : ", Gx-1, " , ", Gy);
			};
			};
	}elif(((Dx == 0) & (Dy > 0))|(Dy > 0)){
		move(s);
		?lastActionResult(Result);
		.print(Result);
		if(Result==success){
			-+position_agent(AgX, AgY+1);
			.print("Move South");
		if(Type == dispenser){
			?thing(NDx, NDy, Type, Details)[entity(A), source(B)];
			+move_to_dispenser(A, NDx, NDy-1);
			.print(" -- UPDATED DISPENSER LOCATION -- :", NDx, " , ", NDy-1);
		}elif(Type == goal){
			?goal_found(A,Gx, Gy);
			-+goal_found(A,Gx, Gy+1);
			.print(" -- UPDATED GOAL LOCATION -- : ", Gx, " , ", Gy+1);
		};
		};
		

	}elif(((Dx == 0) & (Dy < 0))|(Dy < 0)){
		move(n);
		?lastActionResult(Result);
		if(Result == success){
			.print(Result);
			-+position_agent(AgX, AgY-1);
			.print("Move North");
		if(Type == dispenser){
			?thing(NDx, NDy, Type, Details)[entity(A), source(B)];
			+move_to_dispenser(A, NDx, NDy+1);
			.print(" -- UPDATED DISPENSER LOCATION -- :", NDx, " , ", NDy+1);
		}elif(Type == goal){
			?goal_found(A,Gx, Gy);
			-+goal_found(A,Gx, Gy-1);
			.print(" -- UPDATED GOAL LOCATION -- : ", Gx, " , ", Gy-1);
		};
		};		
	}elif((Dx == 0) & (Dy == 0)){
		+agent_moves(randomly_moves);
		!move_random[entity(A), source(B)];
	}.

+!submit_task[entity(A),source(B)]: reached_goal(A,true) & position_agent(AgX, AgY) <-
	?taskList(N, D, B);
	submit(N).
// --------------------- MOVING AWAY FROM OBSTACLE IN PATH --------------------
+!move_away_from_obstacle(D, AgX, AgY)[entity(A),source(B)]: obstacle(ObX, ObY) <-
	// .print("LAST ACTION PARAMETER", D);
	// .print("CURRENT POSITION :", AgX, ",", AgY);
	// ?obstacle(ObX, ObY);
	.print("OBSTACLE CORDINATES : ", ObX," , ", ObY);
	if(D == n){
		move(w);
		?lastActionResult(Result);
		-+position_agent(AgX, (AgY+1));
	}elif(D == e){
		-+position_agent((AgX-1),AgY);
		move(n);
	}elif(D == s){
		-+position_agent(AgX,(AgY-1)); 
		move(e);
	}elif(D == w){
		-+position_agent((AgX+1),AgY);
		move(s);
	};
	?agent_moves(AgAction);
	if(AgAction == search_goal){
		-+agent_moves(search_goal);
	}elif(AgAction == to_dispenser){
		-+agent_moves(to_dispenser);
	}else{
		-+agent_moves(randomly_moves);
	}
	.print("NEW POSITION :", AgX, ",", AgY).

// ------------ POSITION OF AGENT -------------
+position_agent(X,Y) : true <-
	.print("Self Location Inspect :",X,",",Y).

// -------------- THING SEARCH FOR FINDING A DISPENSER ------------------ 
+thing(X, Y, dispenser, Details)[entity(A), source(B)] : found_dispenser(A, false) & agent_moves(randomly_moves) & blockattached(A, false) & not(agent_moves(search_goal)) <-
	.print("X: ",X);
	.print("Y: ",Y);
	// .print("**** ---- AGENT WHO FOUND DISPENSER --- : ", A);
	.print("TYPE : ",dispenser);
	.print("DETAILS : ", Details);
	?position_agent(Nx, Ny);
	// .print(" -- LOCATED A THING -- ");
	// .print(" -- POSTION OF AGENT -- ", Nx , " , ", Ny);
	+found_dispenser(A, true);
	+move_to_dispenser(A,X,Y);
	-agent_moves(randomly_moves);
	+agent_moves(to_dispenser).

// ---- FINDING NEAREST THING -------

// --------- OBSTACLE LOCATION IN THE MAP --------- 
+obstacle(ObX, ObY): true <-
	.print(" -- OBSTACLE FOUND : ", ObX ,",",ObY).

// +!obstacles_list[entity(A), source(B)]: true <-
// 	.findall(obstacle(ObX, ObY),obstacle(ObX, ObY),D);
//     ?mindistance(MinD);
//     for(.member(obstacle(ObX, ObY),D)){
//         ?mindistance(MinD);
//         .print("MinDist",MinD);
//          if(MinD > math.abs(ObX)+math.abs(ObY))
//          {
//             -+mindistance(math.abs(ObX)+math.abs(ObY));
//             -+near_obstacle(A,ObX,ObY);   
//          }
//          else{
//             .print(" -- NOTHING HAPPENED --");
//          };
//         };
// 	.print(" -- NEW CLOSEST OBSTACLE FOUND : ", ObX ,",",ObY);
//     ?near_obstacle(A,ObX,ObY).

// ---------- GOAL LOCATION ON THE MAP ---------
+goal(Gx, Gy)[entity(A),source(B)]: agent_moves(search_goal) & found_goal(A, false) <-
	.print("-- AGENT THAT FOUND A GOAL -- : ", A);
	+found_goal(A, true);
	-agent_moves(search_goal);
	.print(" -- GOAL FOUND  -- : ", Gx,",",Gy);
    +goal_found(A,Gx,Gy).
	
// --------- FIND NEAREST GOAL --------
// +!find_nearest_goal[entity(A),source(B)]: true <-
// 	.findall(goal_found(A,GbX, GbY),goal_found(A,GbX, GbY),D);
//     for(.member(goal_found(A,GbX, GbY),D)){
//         -+nearest_goal(A,GbX,GbY);
// 		+found_goal(A, true);
// 		-agent_moves(search_goal);
//         };
// 	.print(" -- ONE GOAL FOUND : ", GbX ,",",GbY).

// ---------- TASK GENERATED IN THE MAP -----------
+task(Name, DeadLine, Reward, Rtype) :  (.length(Rtype) == 1) & not taskList(Name,_,_) <- 
	.member(req(X,Y,B),Rtype);
	.print(" ************ --- ORIGINAL TASK ---- : ", Rtype);
	.print(" ************ ---- AGENT RECEIVED A TASK : Name=",Name,", Deadline=", DeadLine,", Reward=", Reward,", Type=", B,", X=", X,", Y=",Y," --- *** ");
	+taskList(Name, DeadLine, B).

// -------- LAST ACTION FAILURE CASES CHECKS ------- 
// ------- CHECKS BELIEFS FOR REQUEST -------- 
+lastAction(request) : lastActionResult(failed_blocked) <-
	.print(" --- REQUESTING FAILED BLOCK --- ");
	-+request_block(false);
	-+agent_moves(randomly_moves).

+lastAction(request) : lastActionResult(failed_target) <-
	.print(" --- REQUESTING FAILED TARGET --- ");
	-+request_block(false);
	-+agent_moves(randomly_moves).

// ------ CHECKS BELIEFS FOR ATTACH --------
+lastAction(attach) : lastActionResult(failed_target) <-
	.print(" --- ATTACHING FAILED TARGET --- ");
	-+agent_moves(randomly_moves).

+lastAction(attach) : lastActionResult(failed) <-
	.print(" --- ATTACHING FAILED --- ");
	-+agent_moves(randomly_moves).

// ------ CHECKS BELIEFS FOR SUBMIT -------
+lastAction(submit) : lastActionResult(success) & lastActionParams(Params) & .member(N,Params)<-
	-taskList(N, D, B);
	move(n);
	-+agent_moves(found_goal).

+lastAction(submit) : lastActionResult(failed) & lastActionParams(Params) & .member(N,Params)<-
	-taskList(N, D, B);
	move(s);
	-+agent_moves(found_goal).

+lastAction(rotate): lastActionResult(failed) <-
	-taskList(N, D, B);
	-+agent_moves(randomly_moves).