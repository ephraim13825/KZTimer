// Credits: LJStats by justshoot, Zipcore
public Function_BlockJump(client)
{
	decl Float:pos[3], Float:origin[3];
	GetAimOrigin(client, pos);
	TraceClientGroundOrigin(client, origin, 100.0);
	if(FloatAbs(pos[2] - origin[2]) <= 0.002)
	{
		GetBoxFromPoint(origin, g_OriginBlock[client]);
		GetBoxFromPoint(pos, g_DestBlock[client]);
		CalculateBlockGap(client, origin, pos);
		g_fBlockHeight[client] = pos[2];
	}
	else
	{
		g_bLJBlock[client] = false;
		PrintToChat(client, "%t", "LJblock1",MOSSGREEN,WHITE,RED);	
	}
}

// Credits: LJStats by justshoot, Zipcore
stock TE_SendBlockPoint(client, const Float:pos1[3], const Float:pos2[3], model)
{
	new Float:buffer[4][3];
	buffer[2] = pos1;
	buffer[3] = pos2;
	buffer[0] = buffer[2];
	buffer[0][1] = buffer[3][1];
	buffer[1] = buffer[3];
	buffer[1][1] = buffer[2][1];
	decl randco[4];
	randco[0] = GetRandomInt(0, 255);
	randco[1] = GetRandomInt(0, 255);
	randco[2] = GetRandomInt(0, 255);
	randco[3] = GetRandomInt(125, 255);
	TE_SetupBeamPoints(buffer[3], buffer[0], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[0], buffer[2], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[2], buffer[1], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[1], buffer[3], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
}

// Credits: LJStats by justshoot, Zipcore
GetEdgeOrigin(client, Float:ground[3], Float:result[3])
{
	result[0] = FloatDiv(g_EdgeVector[client][0]*ground[0] + g_EdgeVector[client][1]*g_EdgePoint[client][0], g_EdgeVector[client][0]+g_EdgeVector[client][1]);
	result[1] = FloatDiv(g_EdgeVector[client][1]*ground[1] - g_EdgeVector[client][0]*g_EdgePoint[client][1], g_EdgeVector[client][1]-g_EdgeVector[client][0]);
	result[2] = ground[2];
}

// Credits: LJStats by justshoot, Zipcore
stock TraceWallOrigin(Float:fOrigin[3], Float:vAngles[3], Float:result[3])
{
	new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(trace)) 
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}

// Credits: LJStats by justshoot, Zipcore
stock TraceGroundOrigin(Float:fOrigin[3], Float:result[3])
{
	new Float:vAngles[3] = {90.0, 0.0, 0.0};
	new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(trace)) 
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}

// Credits: LJStats by justshoot, Zipcore
stock GetBeamEndOrigin(Float:fOrigin[3], Float:vAngles[3], Float:distance, Float:result[3])
{
	decl Float:AngleVector[3];
	GetAngleVectors(vAngles, AngleVector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(AngleVector, AngleVector);
	ScaleVector(AngleVector, distance);	
	AddVectors(fOrigin, AngleVector, result);
}

// Credits: LJStats by justshoot, Zipcore
stock GetBeamHitOrigin(Float:fOrigin[3], Float:vAngles[3], Float:result[3])
{
    new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
    if(TR_DidHit(trace)) 
    {
        TR_GetEndPosition(result, trace);
        CloseHandle(trace);
    }
}

// Credits: LJStats by justshoot, Zipcore
stock GetAimOrigin(client, Float:hOrigin[3]) 
{
    new Float:vAngles[3], Float:fOrigin[3];
    GetClientEyePosition(client,fOrigin);
    GetClientEyeAngles(client, vAngles);

    new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

    if(TR_DidHit(trace)) 
    {
        TR_GetEndPosition(hOrigin, trace);
        CloseHandle(trace);
        return 1;
    }

    CloseHandle(trace);
    return 0;
}

// Credits: LJStats by justshoot, Zipcore
stock GetBoxFromPoint(Float:origin[3], Float:result[2][3])
{
	decl Float:temp[3];
	temp = origin;
	temp[2] += 1.0;
	new Float:ang[4][3];
	ang[1][1] = 90.0;
	ang[2][1] = 180.0;
	ang[3][1] = -90.0;
	new bool:edgefound[4];
	new Float:dist[4];
	decl Float:tempdist[4], Float:position[3], Float:ground[3], Float:Last[4], Float:Edge[4][3];
	for(new i = 0; i < 4; i++)
	{
		TraceWallOrigin(temp, ang[i], Edge[i]);
		tempdist[i] = GetVectorDistance(temp, Edge[i]);
		Last[i] = origin[2];
		while(dist[i] < tempdist[i])
		{
			if(edgefound[i])
				break;
			GetBeamEndOrigin(temp, ang[i], dist[i], position);
			TraceGroundOrigin(position, ground);
			if((Last[i] != ground[2])&&(Last[i] > ground[2]))
			{
				Edge[i] = ground;
				edgefound[i] = true;
			}
			Last[i] = ground[2];
			dist[i] += 10.0;
		}
		if(!edgefound[i])
		{
			TraceGroundOrigin(Edge[i], Edge[i]);
			edgefound[i] = true;
		}
		else
		{
			ground = Edge[i];
			ground[2] = origin[2];
			MakeVectorFromPoints(ground, origin, position);
			GetVectorAngles(position, ang[i]);
			ground[2] -= 1.0;
			GetBeamHitOrigin(ground, ang[i], Edge[i]);
		}
		Edge[i][2] = origin[2];
	}
	if(edgefound[0]&&edgefound[1]&&edgefound[2]&&edgefound[3])
	{
		result[0][2] = origin[2];
		result[1][2] = origin[2];
		result[0][0] = Edge[0][0];
		result[0][1] = Edge[1][1];
		result[1][0] = Edge[2][0];
		result[1][1] = Edge[3][1];
	}
}

// Credits: LJStats by justshoot, Zipcore
CalculateBlockGap(client, Float:origin[3], Float:target[3])
{
	new Float:distance = GetVectorDistance(origin, target);
	new Float:rad = DegToRad(15.0);
	new Float:newdistance = FloatDiv(distance, Cosine(rad));
	decl Float:eye[3], Float:eyeangle[2][3];
	new Float:temp = 0.0;
	GetClientEyePosition(client, eye);
	GetClientEyeAngles(client, eyeangle[0]);
	eyeangle[0][0] = 0.0;
	eyeangle[1] = eyeangle[0];
	eyeangle[0][1] += 10.0;
	eyeangle[1][1] -= 10.0;
	decl Float:position[3], Float:ground[3], Float:Last[2], Float:Edge[2][3];
	new bool:edgefound[2];
	while(temp < newdistance)
	{
		temp += 10.0;
		for(new i = 0; i < 2 ; i++)
		{
			if(edgefound[i])
				continue;
			GetBeamEndOrigin(eye, eyeangle[i], temp, position);
			TraceGroundOrigin(position, ground);
			if(temp == 10.0)
			{
				Last[i] = ground[2];
			}
			else
			{
				if((Last[i] != ground[2])&&(Last[i] > ground[2]))
				{
					Edge[i] = ground;
					edgefound[i] = true;
				}
				Last[i] = ground[2];
			}
		}
	}
	decl Float:temp2[2][3];
	if(edgefound[0] && edgefound[1])
	{
		for(new i = 0; i < 2 ; i++)
		{
			temp2[i] = Edge[i];
			temp2[i][2] = origin[2] - 1.0;
			if(eyeangle[i][1] > 0)
			{
				eyeangle[i][1] -= 180.0;
			}
			else
			{
				eyeangle[i][1] += 180.0;
			}
			GetBeamHitOrigin(temp2[i], eyeangle[i], Edge[i]);
		}
	}
	else
	{
		g_bLJBlock[client] = false;
		PrintToChat(client, "%t", "LJblock2",MOSSGREEN,WHITE,RED);	
		return;
	}



	g_EdgePoint[client] = Edge[0];	
	MakeVectorFromPoints(Edge[0], Edge[1], position);
	g_EdgeVector[client] = position;
	NormalizeVector(g_EdgeVector[client], g_EdgeVector[client]);
	CorrectEdgePoint(client);
	GetVectorAngles(position, position);
	position[1] += 90.0;
	GetBeamHitOrigin(Edge[0], position, Edge[1]);
	distance = GetVectorDistance(Edge[0], Edge[1]);
	g_BlockDist[client] = RoundToNearest(distance);


	new Float:surface = GetVectorDistance(g_DestBlock[client][0],g_DestBlock[client][1]);
	surface *= surface;
	if (surface > 1000000)
	{
		PrintToChat(client, "%t", "LJblock3",MOSSGREEN,WHITE,RED);	
		return;
	}	
	
	
	if(!IsCoordInBlockPoint(Edge[1],g_DestBlock[client],true))	
	{	
		g_bLJBlock[client] = false;
		PrintToChat(client, "%t", "LJblock4",MOSSGREEN,WHITE,RED);	
		return;		
	}
	TE_SetupBeamPoints(Edge[0], Edge[1], g_Beam[0], 0, 0, 0, 1.0, 1.0, 1.0, 10, 0.0, {0,255,255,155}, 0);
	TE_SendToClient(client);	
	
	if(g_BlockDist[client] >= 225 && g_BlockDist[client] <= 300)
	{
		PrintToChat(client, "%t", "LJblock5", MOSSGREEN,WHITE, LIMEGREEN,GREEN, g_BlockDist[client],LIMEGREEN);
		g_bLJBlock[client] = true;
	}
	else
	{
		if (g_BlockDist[client] < 225)
			PrintToChat(client, "%t", "LJblock6", MOSSGREEN,WHITE, RED,DARKRED,g_BlockDist[client],RED);
		else
			if (g_BlockDist[client] > 300)
				PrintToChat(client, "%t", "LJblock7", MOSSGREEN,WHITE, RED,DARKRED,g_BlockDist[client],RED);
	}
}

// Credits: LJStats by justshoot, Zipcore
stock bool:IsCoordInBlockPoint(const Float:origin[3], const Float:pos[2][3], bool:ignorez)
{
	new bool:bX, bool:bY, bool:bZ;
	decl Float:temp[2][3];
	temp[0] = pos[0];
	temp[1] = pos[1];
	temp[0][0] += 16.0;
	temp[0][1] += 16.0;
	temp[1][0] -= 16.0;
	temp[1][1] -= 16.0;
	if (ignorez)
		bZ=true;	
	
	if(temp[0][0] > temp[1][0])
	{
		if(temp[0][0] >= origin[0] >= temp[1][0])
		{
			bX = true;
		}
	}
	else
	{
		if(temp[1][0] >= origin[0] >= temp[0][0])
		{
			bX = true;
		}
	}
	if(temp[0][1] > temp[1][1])
	{
		if(temp[0][1] >= origin[1] >= temp[1][1])
		{
			bY = true;
		}
	}
	else
	{
		if(temp[1][1] >= origin[1] >= temp[0][1])
		{
			bY = true;
		}
	}
	if(temp[0][2] + 0.002 >= origin[2] >= temp[0][2])
	{
		bZ = true;
	}
	
	if(bX&&bY&&bZ)
	{
		return true;
	}
	else
	{
		return false;
	}
}

// Credits: LJStats by justshoot, Zipcore
CorrectEdgePoint(client)
{
	decl Float:vec[3];
	vec[0] = 0.0 - g_EdgeVector[client][1];
	vec[1] = g_EdgeVector[client][0];
	vec[2] = 0.0;
	ScaleVector(vec, 16.0);
	AddVectors(g_EdgePoint[client], vec, g_EdgePoint[client]);
}

public Prethink (client, Float:pos[3], Float:vel)
{		
	new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (!client || !IsPlayerAlive(client) || g_bNoClipUsed[client] || weapon == -1 || GetEntProp(client, Prop_Data, "m_nWaterLevel") > 0)
	{	
		g_bNoClipUsed[client] = false;
		return;
	}
	//booster or moving plattform?
	new Float:flVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", flVelocity);
	if (flVelocity[0] != 0.0 || flVelocity[1] != 0.0 || flVelocity[2] != 0.0)
		g_bInvalidGround[client] = true;
	else
		g_bInvalidGround[client] = false;		
			
	//reset vars
	g_good_sync[client] = 0.0;
	g_sync_frames[client] = 0.0;
	for( new i = 0; i < MAX_STRAFES; i++ )
	{
		g_strafe_good_sync[client][i] = 0.0;
		g_strafe_frames[client][i] = 0.0;
		g_strafe_gained[client][i] = 0.0;
		g_strafe_lost[client][i] = 0.0;
		g_strafe_max_speed[client][i] = 0.0;
	}	
	
	g_fJumpOffTime[client] = GetEngineTime();
	g_fMaxSpeed[client] = 0.0;
	g_strafecount[client] = 0;
	g_bDropJump[client] = false;
	g_bPlayerJumped[client] = true;
	g_strafing_aw[client] = false;
	g_strafing_sd[client] = false;
	g_fMaxHeight[client] = -99999.0;				
	g_fLastJumpTime[client] = GetEngineTime();

	decl Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);		
	g_fPreStrafe[client] = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0));	
	g_fTakeOffSpeed[client] = -1.0;
	CreateTimer(0.015, GetTakeOffSpeedTimer, client,TIMER_FLAG_NO_MAPCHANGE);
	GetGroundOrigin(client, g_fJump_Initial[client]);	
	if (g_fJump_InitialLastHeight[client] != -1.012345)
	{	
		new Float: fGroundDiff = g_fJump_Initial[client][2] - g_fJump_InitialLastHeight[client];
		if (fGroundDiff > -0.1 && fGroundDiff < 0.1)
			fGroundDiff = 0.0;		
		if(fGroundDiff != 0.0)
		{		
			if(FloatAbs(fGroundDiff) < 1.5)
			{
				g_fJump_InitialLastHeight[client] = g_fJump_Initial[client][2];
				g_bPlayerJumped[client] = false;
				g_bDropJump[client] = false;
				return;
			}
			g_bDropJump[client] = true;
			g_fDroppedUnits[client] = FloatAbs(fGroundDiff);
		}
	}	
	//last InitialLastHeight
	g_fJump_InitialLastHeight[client] = g_fJump_Initial[client][2];
}

public Postthink(client)
{	
	if (!IsClientInGame(client))
		return;
	new ground_frames = g_ground_frames[client];
	new strafes = g_strafecount[client];
	g_ground_frames[client] = 0;	
	g_fMaxSpeed2[client] = g_fMaxSpeed[client];
	decl String:szName[128];	
	GetClientName(client, szName, 128);		
	
	//get landing position & calc distance
	g_fJump_DistanceX[client] = g_fJump_Final[client][0] - g_fJump_Initial[client][0];
	if(g_fJump_DistanceX[client] < 0)
		g_fJump_DistanceX[client] = -g_fJump_DistanceX[client];
	g_fJump_DistanceZ[client] = g_fJump_Final[client][1] - g_fJump_Initial[client][1];
	if(g_fJump_DistanceZ[client] < 0)
		g_fJump_DistanceZ[client] = -g_fJump_DistanceZ[client];
	g_fJump_Distance[client] = SquareRoot(Pow(g_fJump_DistanceX[client], 2.0) + Pow(g_fJump_DistanceZ[client], 2.0));	
	
	g_fJump_Distance[client] = g_fJump_Distance[client] + 32;
	
	//ground diff
	new Float: fGroundDiff = g_fJump_Final[client][2] - g_fJump_Initial[client][2];
	new Float: fJump_Height;
	if (fGroundDiff > -0.1 && fGroundDiff < 0.1)
		fGroundDiff = 0.0;
	
	//GetHeight
	if (FloatAbs(g_fJump_Initial[client][2]) > FloatAbs(g_fMaxHeight[client]))
		fJump_Height =  FloatAbs(g_fJump_Initial[client][2]) - FloatAbs(g_fMaxHeight[client]);
	else
		fJump_Height =  FloatAbs(g_fMaxHeight[client]) - FloatAbs(g_fJump_Initial[client][2]);
	g_flastHeight[client] = fJump_Height;
	
	//sync/strafes
	new sync = RoundToNearest(g_good_sync[client] / g_sync_frames[client] * 100.0);
	g_Strafes[client] = strafes;
	g_sync[client] = sync;
	
	
	//Calc & format strafe sync for chat output
	new String:szStrafeSync[255];
	new String:szStrafeSync2[255];
	new strafe_sync;
	if (g_bStrafeSync[client] && strafes > 1)
	{
		for (new i = 0; i < strafes; i++)
		{
			if (i==0)
				Format(szStrafeSync, 255, "[%cKZ%c] %cSync:",MOSSGREEN,WHITE,GRAY);
			if (g_strafe_frames[client][i] == 0.0 || g_strafe_good_sync[client][i] == 0.0) 
				strafe_sync = 0;
			else
				strafe_sync = RoundToNearest(g_strafe_good_sync[client][i] / g_strafe_frames[client][i] * 100.0);
			if (i==0)	
				Format(szStrafeSync2, 255, " %c%i.%c %i%c",GRAY, (i+1),LIMEGREEN,strafe_sync,PERCENT);
			else
				Format(szStrafeSync2, 255, "%c - %i.%c %i%c",GRAY, (i+1),LIMEGREEN,strafe_sync,PERCENT);
			StrCat(szStrafeSync, sizeof(szStrafeSync), szStrafeSync2);
			if ((i+1) == strafes)
			{
				Format(szStrafeSync2, 255, " %c[%c%i%c%c]",GRAY,PURPLE, sync,PERCENT,GRAY);
				StrCat(szStrafeSync, sizeof(szStrafeSync), szStrafeSync2);
			}
		}	
	}
	else
		Format(szStrafeSync,255, "");
		
	new String:szStrafeStats[1024];
	new String:szGained[16];
	new String:szLost[16];
	
	//Format StrafeStats Console
	if(strafes > 1)
	{
		Format(szStrafeStats,1024, " #. Sync        Gained      Lost        MaxSpeed\n");
		for( new i = 0; i < strafes; i++ )
		{
			new sync2 = RoundToNearest(g_strafe_good_sync[client][i] / g_strafe_frames[client][i] * 100.0);
			if (sync2 < 0)
				sync2 = 0;
			if (g_strafe_gained[client][i] < 10.0)
				Format(szGained,16, "%.3f ", g_strafe_gained[client][i]);
			else
				Format(szGained,16, "%.3f", g_strafe_gained[client][i]);
			if (g_strafe_lost[client][i] < 10.0)
				Format(szLost,16, "%.3f ", g_strafe_lost[client][i]);
			else
				Format(szLost,16, "%.3f", g_strafe_lost[client][i]);				
			Format(szStrafeStats,1024, "%s%2i. %3i%s        %s      %s      %3.3f\n",\
			szStrafeStats,\
			i + 1,\
			sync2,\
			PERCENT,\
			szGained,\
			szLost,\
			g_strafe_max_speed[client][i]);
		}
	}
	else
		Format(szStrafeStats,1024, "");
	
	//t00-b4d
	if(g_fJump_Distance[client] < 200.0)
	{
		//multibhop count proforma
		if (g_last_ground_frames[client] < 11 && ground_frames < 11 && fGroundDiff == 0.0  && fJump_Height <= 67.0 && !g_bDropJump[client])
			g_multi_bhop_count[client]++;
		else
			g_multi_bhop_count[client]=1;
		if (fGroundDiff==0.0)
			g_fLastJumpDistance[client] = g_fJump_Distance[client];	
		PostThinkPost(client, ground_frames);
		return;
	}
	


	//change BotName (szName) for jumpstats output
	if (client == g_iBot)
		Format(szName,sizeof(szName), "%s (Pro Replay)", g_szReplayName);		
	if (client == g_iBot2)
		Format(szName,sizeof(szName), "%s (TP Replay)", g_szReplayNameTp);	
	
	//Chat Output
	//LongJump
	if (ground_frames > 11 && fGroundDiff == 0.0 && 200.0 < g_fPreStrafe[client] < 278.0 && fJump_Height <= 67.0 && g_fJump_Distance[client] < 300.0 && g_fMaxSpeed2[client] > 200.0) 
	{	
		//strafe hack block
		if (g_bPreStrafe)
		{
			if ((g_tickrate == 64 && strafes < 4 && g_fJump_Distance[client] > 265.0) || (g_tickrate == 102 && strafes < 4 && g_fJump_Distance[client] > 270.0) || (g_tickrate == 128 && strafes < 4 && g_fJump_Distance[client] > 275.0)) 
			{
				PostThinkPost(client, ground_frames);
				return;
			}				
		}
		else
		{
			if ((g_tickrate == 64 && strafes < 4 && g_fJump_Distance[client] > 250.0) || (g_tickrate == 102 && strafes < 4 && g_fJump_Distance[client] > 255.0) || (g_tickrate == 128 && strafes < 4 && g_fJump_Distance[client] > 260.0)) 
			{
				PostThinkPost(client, ground_frames);
				return;
			}
		}
		if (strafes > 20)
		{
			PostThinkPost(client, ground_frames);
			return;
		}			
			
		//block invalid bot distances (has something to do with the ground-detection of the replay bot) WORKAROUND
		if (IsFakeClient(client) && g_fJump_Distance[client] > (g_dist_leet_lj * 1.02))
		{
			PostThinkPost(client, ground_frames);
			return;
		}
		
		//last distance (speedmeter)
		g_fLastJumpDistance[client] = g_fJump_Distance[client];
		
		//check if kz_prestrafe is enabled
		decl String:szVr[16];	
		if (!g_bPreStrafe)	
		{
			g_fPreStrafe[client] = g_fTakeOffSpeed[client];
			Format(szVr, 16, "TakeOff");
		}
		else
			Format(szVr, 16, "Pre");		
		
		new bool:ljblock=false;	
		decl String:sBlockDist[32];	
		Format(sBlockDist, 32, "");	
		decl String:sBlockDistCon[32];	
		Format(sBlockDistCon, 32, "");	
		if(g_bLJBlock[client] && g_BlockDist[client] > 225 && g_fJump_Distance[client] >= float(g_BlockDist[client]))
		{
			if (g_bLJBlockValidJumpoff[client])
			{
				if (g_bLjStarDest[client])
				{
					if (IsCoordInBlockPoint(g_fJump_Final[client],g_OriginBlock[client],false))
					{
						Format(sBlockDist, 32, " %c[%c%i block%c]", GRAY,YELLOW,g_BlockDist[client],GRAY);	
						Format(sBlockDistCon, 32, " [%i block]", g_BlockDist[client]);	
						ljblock=true;
					}
				}
				else
				{
					if (IsCoordInBlockPoint(g_fJump_Final[client],g_DestBlock[client],false))
					{
						Format(sBlockDist, 32, " %c[%c%i block%c]", GRAY,YELLOW,g_BlockDist[client],GRAY);	
						Format(sBlockDistCon, 32, " [%i block]", g_BlockDist[client]);	
						ljblock=true;			
					}
				}
			}
		}
		//good?
		if (g_fJump_Distance[client] >= g_dist_good_lj && g_fJump_Distance[client] < g_dist_pro_lj)	
		{
			g_LeetJumpDominating[client]=0;		
			PrintToChat(client, "[%cKZ%c] %cLJ: %.2f units [%c%i%c Strafes | %c%.0f%c %s | %c%3.f%c Max | %c%.0f%c Height | %c%i%c%c Sync]%s",MOSSGREEN,WHITE,GRAY, g_fJump_Distance[client],LIMEGREEN,strafes,GRAY, LIMEGREEN, g_fPreStrafe[client], GRAY,szVr,LIMEGREEN,g_fMaxSpeed2[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);			
			PrintToConsole(client, "        ");
			PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LongJump [%i Strafes | %.3f %s | %.3f Max | Height %.1f | %i%c Sync]%s",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], szVr,g_fMaxSpeed2[client],fJump_Height,sync,PERCENT,sBlockDistCon);
			PrintToConsole(client, "%s", szStrafeStats);
			}
		else
			//pro?
			if (g_fJump_Distance[client] >= g_dist_pro_lj && g_fJump_Distance[client] < g_dist_leet_lj)	
			{
				g_LeetJumpDominating[client]=0;
				//chat & sound client		
				PrintToConsole(client, "        ");
				PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LongJump [%i Strafes | %.3f %s | %.3f Max | Height %.1f | %i%c Sync]%s",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client],szVr, g_fMaxSpeed2[client],fJump_Height,sync,PERCENT,sBlockDistCon);
				PrintToConsole(client, "%s", szStrafeStats);		
				PrintToChat(client, "[%cKZ%c] %cLJ%c: %c%.2f units%c [%c%i%c Strafes | %c%.0f%c %s |  %c%0.f%c Max | %c%.0f%c Height | %c%i%c%c Sync]%s",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_fPreStrafe[client],GRAY,szVr,LIMEGREEN,g_fMaxSpeed2[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);
				decl String:buffer[255];
				Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH); 			
				if (g_bEnableQuakeSounds[client])
					ClientCommand(client, buffer); 						
				PlayQuakeSound_Spec(client,buffer);		
				//chat all
				for (new i = 1; i <= MaxClients; i++)
				{
					if (1 <= i <= MaxClients && IsClientInGame(i) && IsValidEntity(i))
					{						
						if (g_bColorChat[i] && i != client)
							PrintToChat(i, "%t", "Jumpstats_LjAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_fJump_Distance[client],MOSSGREEN,GREEN,sBlockDist);
					}
				}	
				
			}	
			//leet?
			else		
			{	
				if (g_fJump_Distance[client] >= g_dist_leet_lj)	
				{
					g_LeetJumpDominating[client]++;
					//client		
					PrintToConsole(client, "        ");
					PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LongJump [%i Strafes | %.3f %s | %.3f Max | Height %.1f | %i%c Sync]%s",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client],szVr, g_fMaxSpeed2[client],fJump_Height,sync,PERCENT,sBlockDistCon);
					PrintToConsole(client, "%s", szStrafeStats);						
					PrintToChat(client, "[%cKZ%c] %cLJ%c: %c%.2f units%c [%c%i%c Strafes | %c%.0f%c %s | %c%0.f%c Max | %c%.0f%c Height | %c%i%c%c Sync]%s",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_fPreStrafe[client],GRAY,szVr,LIMEGREEN, g_fMaxSpeed2[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);
					if (g_LeetJumpDominating[client]==3)
						PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
					else
						if (g_LeetJumpDominating[client]==5)
							PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
					
					//all
					for (new i = 1; i <= MaxClients; i++)
					{
						if (1 <= i <= MaxClients && IsClientInGame(i) && IsValidEntity(i))
						{						
							if (g_bColorChat[i] && i != client)
							{
								PrintToChat(i, "%t", "Jumpstats_LjAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_fJump_Distance[client],RED,DARKRED,sBlockDist);
								if (g_LeetJumpDominating[client]==3)
									PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
								else
									if (g_LeetJumpDominating[client]==5)
										PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
							}
						}
					}
					PlayLeetJumpSound(client);
					if (g_LeetJumpDominating[client] != 3 && g_LeetJumpDominating[client] != 5)
					{
						decl String:buffer[255];
						Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 	
						PlayQuakeSound_Spec(client,buffer);
					}
				}
				else
					g_LeetJumpDominating[client] = 0;
			}
	
		//strafe sync chat
		if (g_bStrafeSync[client] && g_fJump_Distance[client] >= g_dist_good_lj)
			PrintToChat(client,"%s", szStrafeSync);		
				
		//new best
		if (((g_fPersonalLjRecord[client] < g_fJump_Distance[client]) || (ljblock && g_PersonalLjBlockRecord[client] < g_BlockDist[client]) || (ljblock && g_PersonalLjBlockRecord[client] == g_BlockDist[client] && g_fPersonalLjBlockRecordDist[client] < g_fJump_Distance[client])) && !IsFakeClient(client))
		{		
			if (g_fPersonalLjRecord[client] > 0.0 && g_fPersonalLjRecord[client] < g_fJump_Distance[client])
				PrintToChat(client, "%t", "Jumpstats_BeatLjBest",MOSSGREEN,WHITE,YELLOW, g_fJump_Distance[client]);
			if (ljblock && g_PersonalLjBlockRecord[client] > 0 && ((g_PersonalLjBlockRecord[client] < g_BlockDist[client]) || (g_PersonalLjBlockRecord[client] == g_BlockDist[client] && g_fPersonalLjBlockRecordDist[client] < g_fJump_Distance[client])))
				PrintToChat(client, "%t", "Jumpstats_BeatLjBlockBest",MOSSGREEN,WHITE,YELLOW, g_BlockDist[client],g_fJump_Distance[client]);
			if (g_fPersonalLjRecord[client] < g_fJump_Distance[client])
			{	
				g_fPersonalLjRecord[client] = g_fJump_Distance[client];
				db_updateLjRecord(client);
			}
			if (g_PersonalLjBlockRecord[client] < g_BlockDist[client] && ljblock || (ljblock && g_PersonalLjBlockRecord[client] == g_BlockDist[client] && g_fPersonalLjBlockRecordDist[client] < g_fJump_Distance[client]))
			{
				g_PersonalLjBlockRecord[client] = g_BlockDist[client];
				g_fPersonalLjBlockRecordDist[client] = g_fJump_Distance[client];
				db_updateLjBlockRecord(client);
			}
			
			
		}
	}
	//Multi Bhop
	if (g_last_ground_frames[client] < 11 && ground_frames < 11 && fGroundDiff == 0.0  && fJump_Height <= 67.0 && !g_bDropJump[client])
	{		
	
		g_multi_bhop_count[client]++;	
		//block boost through a booster (e.g. bhop_monster_jam_b1 vip room exit) && strafehack protection
		if (((g_multi_bhop_count[client] == 1 && g_fPreStrafe[client] > 350.0) || strafes > 20) || (g_fBhopSpeedCap == 380.0 && g_fJump_Distance[client] > 380.0))
		{
			PostThinkPost(client, ground_frames);
			return;		
		}

		//block invalid bot distances (has something to do with the ground-detection of the replay bot) WORKAROUND
		if (IsFakeClient(client) && g_fJump_Distance[client] > (g_dist_leet_multibhop * 1.025))
		{
			PostThinkPost(client, ground_frames);
			return;
		}
		
		g_fLastJumpDistance[client] = g_fJump_Distance[client];			
		
		//format bhop count
		decl String:szBhopCount[255];
		Format(szBhopCount, sizeof(szBhopCount), "%i", g_multi_bhop_count[client]);
		if (g_multi_bhop_count[client] > 8)
			Format(szBhopCount, sizeof(szBhopCount), "> 8");
		
		//good?	
		if (g_fJump_Distance[client] >= g_dist_good_multibhop && g_fJump_Distance[client] < g_dist_pro_multibhop)	
		{
			g_LeetJumpDominating[client]=0;
			PrintToChat(client, "[%cKZ%c] %cMultiBhop: %.2f units [%c%i%c Strafes | %c%.0f%c Pre | %c%i%c%c Sync]",MOSSGREEN,WHITE, GRAY, g_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_fPreStrafe[client], GRAY, LIMEGREEN, sync,PERCENT,GRAY);	
			PrintToConsole(client, "        ");
			PrintToConsole(client, "[KZ] %s jumped %0.4f units with a MultiBhop [%i Strafes | %3.f Pre | %3.f Max | Height %.1f | %s Bhops | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client], fJump_Height,szBhopCount,sync,PERCENT);				
			PrintToConsole(client, "%s", szStrafeStats);
		}	
		else
			//pro?
			if (g_fJump_Distance[client] >= g_dist_pro_multibhop && g_fJump_Distance[client] < g_dist_leet_multibhop)
			{				
				g_LeetJumpDominating[client]=0;
				//Client
				PrintToConsole(client, "        ");
				PrintToConsole(client, "[KZ] %s jumped %0.4f units with a MultiBhop [%i Strafes | %.3f Pre | %.3f Max |  Height %.1f | %s Bhops | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client], fJump_Height,szBhopCount,sync,PERCENT);				
				PrintToConsole(client, "%s", szStrafeStats);					
				PrintToChat(client, "[%cKZ%c] %cMultiBhop%c: %c%.2f units%c [%c%i%c Strafes | %c%.0f%c Pre |  %c%0.f%c Max | %c%.0f%c Height | %c%s%c Bhops | %c%i%c%c Sync]",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_fPreStrafe[client],GRAY,LIMEGREEN,g_fMaxSpeed2[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN,szBhopCount,GRAY,LIMEGREEN, sync,PERCENT,GRAY);
				
				decl String:buffer[255];
				Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH); 
				if (g_bEnableQuakeSounds[client])
					ClientCommand(client, buffer); 
				PlayQuakeSound_Spec(client,buffer);				
				//all
				for (new i = 1; i <= MaxClients; i++)
				{
					if (1 <= i <= MaxClients && IsClientInGame(i) && IsValidEntity(i))
					{
						if (g_bColorChat[i] && i != client)					
							PrintToChat(i, "%t", "Jumpstats_MultiBhopAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_fJump_Distance[client],MOSSGREEN,GREEN);
					}
				}
			}
			//leet?
			else
			if (g_fJump_Distance[client] >= g_dist_leet_multibhop)	
			{
				g_LeetJumpDominating[client]++;
				//Client
				PrintToConsole(client, "        ");
				PrintToConsole(client, "[KZ] %s jumped %0.4f units with a MultiBhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %s Bhops | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client], fJump_Height,szBhopCount,sync,PERCENT);
				PrintToConsole(client, "%s", szStrafeStats);
				PrintToChat(client, "[%cKZ%c] %cMultiBhop%c: %c%.2f units%c [%c%i%c Strafes | %c%.0f%c Pre |  %c%0.f%c Max | %c%.0f%c Height | %c%s%c Bhops | %c%i%c%c Sync]",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_fPreStrafe[client],GRAY,LIMEGREEN,g_fMaxSpeed2[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN,szBhopCount,GRAY,LIMEGREEN, sync,PERCENT,GRAY);
				if (g_LeetJumpDominating[client]==3)
					PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
				else
				if (g_LeetJumpDominating[client]==5)
					PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);						
			
				//all
				for (new i = 1; i <= MaxClients; i++)
				{
					if (1 <= i <= MaxClients && IsClientInGame(i))
					{
						if (g_bColorChat[i] && i != client)
						{
							PrintToChat(i, "%t", "Jumpstats_MultiBhopAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_fJump_Distance[client],RED,DARKRED);
							if (g_LeetJumpDominating[client]==3)
									PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
								else
								if (g_LeetJumpDominating[client]==5)
									PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
						}
					}
				}
				PlayLeetJumpSound(client);	
				if (g_LeetJumpDominating[client] != 3 && g_LeetJumpDominating[client] != 5)
				{
					decl String:buffer[255];
					Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 	
					PlayQuakeSound_Spec(client,buffer);
				}
			}	
			else
				g_LeetJumpDominating[client]=0;
		
		//strafe sync chat
		if (g_bStrafeSync[client] && g_fJump_Distance[client] >= g_dist_good_multibhop)
			PrintToChat(client,"%s", szStrafeSync);		
		
		//new best
		if (g_fPersonalMultiBhopRecord[client] < g_fJump_Distance[client] &&  !IsFakeClient(client))
		{
			if (g_fPersonalMultiBhopRecord[client] > 0.0)
				PrintToChat(client, "%t", "Jumpstats_BeatMultiBhopBest",MOSSGREEN,WHITE,YELLOW, g_fJump_Distance[client]);
			g_fPersonalMultiBhopRecord[client] = g_fJump_Distance[client];
			db_updateMultiBhopRecord(client);
		}
	}
	else
		g_multi_bhop_count[client] = 1;	

	//dropbhop
	if (ground_frames < 11 && g_last_ground_frames[client] > 11 && g_bLastButtonJump[client] && fGroundDiff == 0.0 && fJump_Height <= 67.0 && g_bDropJump[client])
	{		
		if (g_fDroppedUnits[client] > 132.0)
		{
			if (g_fDroppedUnits[client] < 300.0)
				PrintToChat(client, "[%cKZ%c] You fell too far. (%c%.1f%c/%c132.0%c max) %cDropBhop%c",MOSSGREEN,WHITE,RED,g_fDroppedUnits[client],WHITE,GREEN,WHITE,GRAY,WHITE);
		}
		else
		{
			if (g_fPreStrafe[client] > g_fMaxBhopPreSpeed)
				PrintToChat(client, "[%cKZ%c] Your Prestrafe is too high. (%c%.3f%c/%c%.1f%c max) %cDropBhop%c",MOSSGREEN,WHITE,RED,g_fPreStrafe[client],WHITE,GREEN,g_fMaxBhopPreSpeed,WHITE,GRAY,WHITE);
			else
			{
				
				//block invalid bot distances (has something to do with the ground-detection of the replay bot) WORKAROUND
				if ((IsFakeClient(client) && g_fJump_Distance[client] > (g_dist_leet_dropbhop * 1.05)) || strafes > 20)
				{
					PostThinkPost(client, ground_frames);
					return;
				}
				
				g_fLastJumpDistance[client] = g_fJump_Distance[client];
				if (g_fJump_Distance[client] >= g_dist_good_dropbhop && g_fJump_Distance[client] < g_dist_pro_dropbhop)	
				{
					g_LeetJumpDominating[client]=0;	
					PrintToChat(client, "[%cKZ%c] %cDropBhop: %.2f units [%c%i%c Strafes | %c%.0f%c Pre  | %c%.0f%c Height | %c%i%c%c Sync]",MOSSGREEN,WHITE, GRAY,g_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_fPreStrafe[client], GRAY, LIMEGREEN,fJump_Height,GRAY, LIMEGREEN,sync,PERCENT,GRAY);	
					PrintToConsole(client, "        ");
					PrintToConsole(client, "[KZ] %s jumped %0.4f units with a DropBhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client],fJump_Height,sync,PERCENT);						
					PrintToConsole(client, "%s", szStrafeStats);
				}	
				else
				if (g_fJump_Distance[client] >= g_dist_pro_dropbhop && g_fJump_Distance[client] < g_dist_leet_dropbhop)
				{
						g_LeetJumpDominating[client]=0;
						//Client
						PrintToConsole(client, "        ");
						PrintToChat(client, "[%cKZ%c] %cDropBhop%c: %c%.2f units%c [%c%i%c Strafes | %c%0.f%c Pre | %c%0.f%c Max  | %c%.0f%c Height | %c%i%c%c Sync]",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_fPreStrafe[client],GRAY,LIMEGREEN, g_fMaxSpeed2[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN,sync,PERCENT,GRAY);	
						PrintToConsole(client, "[KZ] %s jumped %0.4f units with a DropBhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client],fJump_Height,sync,PERCENT);						
						PrintToConsole(client, "%s", szStrafeStats);
						decl String:buffer[255];
						Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH); 
						if (g_bEnableQuakeSounds[client])
							ClientCommand(client, buffer); 
						PlayQuakeSound_Spec(client,buffer);	
						//all
						for (new i = 1; i <= MaxClients; i++)
						{
							if (1 <= i <= MaxClients && IsClientInGame(i))
							{
								if (g_bColorChat[i]==true && i != client)
									PrintToChat(i, "%t", "Jumpstats_DropBhopAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_fJump_Distance[client],MOSSGREEN,GREEN);
							}
						}
					}
					else
						if (g_fJump_Distance[client] >= g_dist_leet_dropbhop)	
						{						
							g_LeetJumpDominating[client]++;
							//Client
							PrintToConsole(client, "        ");
							PrintToChat(client, "[%cKZ%c] %cDropBhop%c: %c%.2f units%c [%c%i%c Strafes | %c%0.f%c Pre | %c%0.f%c Max | %c%.0f%c Height | %c%i%c%c Sync]",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_fPreStrafe[client],GRAY,LIMEGREEN, g_fMaxSpeed2[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);	
							PrintToConsole(client, "[KZ] %s jumped %0.4f units with a DropBhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client],fJump_Height,sync,PERCENT);
							PrintToConsole(client, "%s", szStrafeStats);
							if (g_LeetJumpDominating[client]==3)
								PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
							else
								if (g_LeetJumpDominating[client]==5)
									PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
									
							//all
							for (new i = 1; i <= MaxClients; i++)
							{
								if (1 <= i <= MaxClients && IsClientInGame(i))
								{
									if (g_bColorChat[i]==true && i != client)
									{
										PrintToChat(i, "%t", "Jumpstats_DropBhopAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_fJump_Distance[client], RED,DARKRED);
										if (g_LeetJumpDominating[client]==3)
												PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
										else
											if (g_LeetJumpDominating[client]==5)
												PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
									}
								}	
							}
							PlayLeetJumpSound(client);	
							if (g_LeetJumpDominating[client] != 3 && g_LeetJumpDominating[client] != 5)
							{
								decl String:buffer[255];
								Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 	
								PlayQuakeSound_Spec(client,buffer);
							}
						}		
						else
							g_LeetJumpDominating[client]=0;
				
				//strafesync chat
				if (g_bStrafeSync[client] && g_fJump_Distance[client] >= g_dist_good_dropbhop)
					PrintToChat(client,"%s", szStrafeSync);	
				
				//new best
				if (g_fPersonalDropBhopRecord[client] < g_fJump_Distance[client]  &&  !IsFakeClient(client))
				{
					if (g_fPersonalDropBhopRecord[client] > 0.0)
						PrintToChat(client, "%t", "Jumpstats_BeatDropBhopBest",MOSSGREEN,WHITE,YELLOW, g_fJump_Distance[client]);
					g_fPersonalDropBhopRecord[client] = g_fJump_Distance[client];
					db_updateDropBhopRecord(client);
				}				
			}
		}
	}
	// WeirdJump
	if (ground_frames < 11 && !g_bLastButtonJump[client] && fGroundDiff == 0.0 && fJump_Height <= 67.0 && g_bDropJump[client])
	{						
			if (g_fDroppedUnits[client] > 132.0)
			{
				if (g_fDroppedUnits[client] < 300.0)
					PrintToChat(client, "[%cKZ%c] You fell too far. (%c%.1f%c/%c132.0%c max) %cWJ%c",MOSSGREEN,WHITE,RED,g_fDroppedUnits[client],WHITE,GREEN,WHITE,GRAY,WHITE);
			}
			else
			{
				if (g_fPreStrafe[client] > 300)
					PrintToChat(client, "[%cKZ%c] Your Prestrafe is too high. (%c%.3f%c/%c300.0%c max) %cWJ%c",MOSSGREEN,WHITE,RED,g_fPreStrafe[client],WHITE,GREEN,WHITE,GRAY,WHITE);
				else
				{
					//block invalid bot distances (has something to do with the ground-detection of the replay bot) WORKAROUND
					if ((IsFakeClient(client) && g_fJump_Distance[client] > (g_dist_leet_weird * 1.05)) || strafes > 20)
					{
						PostThinkPost(client, ground_frames);
						return;
					}					
						
					g_fLastJumpDistance[client] = g_fJump_Distance[client];
					
					//good?
					if (g_fJump_Distance[client] >= g_dist_good_weird && g_fJump_Distance[client] < g_dist_pro_weird)	
					{
						g_LeetJumpDominating[client]=0;
						PrintToChat(client, "[%cKZ%c] %cWJ: %.2f units [%c%i%c Strafes | %c%.0f%c Pre | %c%.0f%c Height | %c%i%c%c Sync]",MOSSGREEN,WHITE, GRAY,g_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_fPreStrafe[client], GRAY, LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);	
						PrintToConsole(client, "        ");
						PrintToConsole(client, "[KZ] %s jumped %0.4f units with a WeirdJump [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client],fJump_Height,sync,PERCENT);						
						PrintToConsole(client, "%s", szStrafeStats);	
					}	
					//pro?
					else
						if (g_fJump_Distance[client] >= g_dist_pro_weird && g_fJump_Distance[client] < g_dist_leet_weird)
						{
							g_LeetJumpDominating[client]=0;
							//Client
							PrintToConsole(client, "        ");
							PrintToChat(client, "[%cKZ%c] %cWJ%c: %c%.2f units%c [%c%i%c Strafes | %c%0.f%c Pre | %c%0.f%c Max | %c%.0f%c Height | %c%i%c%c Sync]",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_fPreStrafe[client],GRAY,LIMEGREEN, g_fMaxSpeed2[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
							PrintToConsole(client, "[KZ] %s jumped %0.4f units with a WeirdJump [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client],fJump_Height,sync,PERCENT);						
							PrintToConsole(client, "%s", szStrafeStats);
							decl String:buffer[255];
							Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH); 
							if (g_bEnableQuakeSounds[client])
								ClientCommand(client, buffer); 
							PlayQuakeSound_Spec(client,buffer);	
							//all
							for (new i = 1; i <= MaxClients; i++)
							{
								if (1 <= i <= MaxClients && IsClientInGame(i))
								{
									if (g_bColorChat[i]==true && i != client)
										PrintToChat(i, "%t", "Jumpstats_WeirdAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_fJump_Distance[client],MOSSGREEN,GREEN);
								}
							}
						}
						//leet?
						else
							if (g_fJump_Distance[client] >= g_dist_leet_weird)	
							{
								g_LeetJumpDominating[client]++;
								//Client
								PrintToConsole(client, "        ");
								PrintToChat(client, "[%cKZ%c] %cWJ%c: %c%.2f units%c [%c%i%c Strafes | %c%0.f%c Pre | %c%0.f%c Max | %c%.0f%c Height | %c%i%c%c Sync]",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_fPreStrafe[client],GRAY,LIMEGREEN, g_fMaxSpeed2[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
								PrintToConsole(client, "[KZ] %s jumped %0.4f units with a WeirdJump [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client],fJump_Height,sync,PERCENT);
								PrintToConsole(client, "%s", szStrafeStats);
								if (g_LeetJumpDominating[client]==3)
									PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
								else
									if (g_LeetJumpDominating[client]==5)
										PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
													
								//all
								for (new i = 1; i <= MaxClients; i++)
								{
									if (1 <= i <= MaxClients && IsClientInGame(i))
									{
										if (g_bColorChat[i]==true && i != client)
										{
											PrintToChat(i, "%t", "Jumpstats_WeirdAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_fJump_Distance[client],RED,DARKRED);
											if (g_LeetJumpDominating[client]==3)
													PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
												else
												if (g_LeetJumpDominating[client]==5)
													PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
										}
									}
								}
								PlayLeetJumpSound(client);
								if (g_LeetJumpDominating[client] != 3 && g_LeetJumpDominating[client] != 5)
								{
									decl String:buffer[255];
									Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 	
									PlayQuakeSound_Spec(client,buffer);
								}								
							}		
								else
									g_LeetJumpDominating[client]=0;		
					
					//strafesync chat
					if (g_bStrafeSync[client]  && g_fJump_Distance[client] >= g_dist_good_weird)
						PrintToChat(client,"%s", szStrafeSync);	
						
					//new best
					if (g_fPersonalWjRecord[client] < g_fJump_Distance[client]  &&  !IsFakeClient(client))
					{
						if (g_fPersonalWjRecord[client] > 0.0)
							PrintToChat(client, "%t", "Jumpstats_BeatWjBest",MOSSGREEN,WHITE,YELLOW, g_fJump_Distance[client]);
						g_fPersonalWjRecord[client] = g_fJump_Distance[client];
						db_updateWjRecord(client);
					}
				}
			}
	}
	//BunnyHop
	if (ground_frames < 11 && g_last_ground_frames[client] > 10 && fGroundDiff == 0.0 && fJump_Height <= 67.0 && !g_bDropJump[client] && g_fPreStrafe[client] > 200.0)
	{
			//block invalid bot distances (has something to do with the ground-detection of the replay bot) WORKAROUND
			if (((IsFakeClient(client) && g_fJump_Distance[client] > (g_dist_leet_bhop * 1.05)) || g_fJump_Distance[client] > 400.0) || strafes > 20)
			{
				PostThinkPost(client, ground_frames);
				return;
			}
			
			if (g_fPreStrafe[client]> g_fMaxBhopPreSpeed)
					PrintToChat(client, "[%cKZ%c] Your Prestrafe is too high. (%c%.3f%c/%c%.1f%c max) %cBhop%c",MOSSGREEN,WHITE,RED,g_fPreStrafe[client],WHITE,GREEN,g_fMaxBhopPreSpeed,WHITE,GRAY,WHITE);
			else
			{	
				g_fLastJumpDistance[client] = g_fJump_Distance[client];
				//good?
				if (g_fJump_Distance[client] >= g_dist_good_bhop && g_fJump_Distance[client] < g_dist_pro_bhop)	
				{
					g_LeetJumpDominating[client]=0;
					PrintToChat(client, "[%cKZ%c] %cBhop: %.2f units [%c%i%c Strafes | %c%.0f%c Pre | %c%.0f%c Height | %c%i%c%c Sync]",MOSSGREEN,WHITE,GRAY, g_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_fPreStrafe[client], GRAY, LIMEGREEN, fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);	
					PrintToConsole(client, "        ");
					PrintToConsole(client, "[KZ] %s jumped %0.4f units with a Bhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client],fJump_Height,sync,PERCENT);						
					PrintToConsole(client, "%s", szStrafeStats);
				}	
				else
					//pro?
					if (g_fJump_Distance[client] >= g_dist_pro_bhop && g_fJump_Distance[client] < g_dist_leet_bhop)
					{
						g_LeetJumpDominating[client]=0;
						//Client
						PrintToConsole(client, "        ");
						PrintToChat(client, "[%cKZ%c] %cBhop%c: %c%.2f units%c [%c%i%c Strafes | %c%0.f%c Pre | %c%0.f%c Max | %c%.0f%c Height | %c%i%c%c Sync]",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_fPreStrafe[client],GRAY,LIMEGREEN, g_fMaxSpeed2[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
						PrintToConsole(client, "[KZ] %s jumped %0.4f units with a Bhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client],fJump_Height, sync,PERCENT);						
						PrintToConsole(client, "%s", szStrafeStats);
						decl String:buffer[255];
						Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH); 
						if (g_bEnableQuakeSounds[client])
							ClientCommand(client, buffer); 
						PlayQuakeSound_Spec(client,buffer);	
						//all
						for (new i = 1; i <= MaxClients; i++)
						{
							if (1 <= i <= MaxClients && IsClientInGame(i))
							{
								if (g_bColorChat[i]==true && i != client)
									PrintToChat(i, "%t", "Jumpstats_BhopAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_fJump_Distance[client],MOSSGREEN,GREEN);
							}
						}
					}
					else
						//leet?
						if (g_fJump_Distance[client] >= g_dist_leet_bhop)	
						{
							g_LeetJumpDominating[client]++;
							//Client
							PrintToConsole(client, "        ");
							PrintToChat(client, "[%cKZ%c] %cBhop%c: %c%.2f units%c [%c%i%c Strafes | %c%0.f%c Pre | %c%0.f%c Max | %c%.0f%c Height | %c%i%c%c Sync]",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_fPreStrafe[client],GRAY,LIMEGREEN, g_fMaxSpeed2[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
							PrintToConsole(client, "[KZ] %s jumped %0.4f units with a Bhop [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync]",szName, g_fJump_Distance[client],strafes, g_fPreStrafe[client], g_fMaxSpeed2[client],fJump_Height, sync,PERCENT);
							PrintToConsole(client, "%s", szStrafeStats);
							if (g_LeetJumpDominating[client]==3)
								PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
							else
							if (g_LeetJumpDominating[client]==5)
										PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
											
							//all
							for (new i = 1; i <= MaxClients; i++)
							{
								if (1 <= i <= MaxClients && IsClientInGame(i))
								{
									if (g_bColorChat[i]==true && i != client)
									{
										PrintToChat(i, "%t", "Jumpstats_BhopAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_fJump_Distance[client],RED,DARKRED);
										if (g_LeetJumpDominating[client]==3)
											PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
										else
											if (g_LeetJumpDominating[client]==5)
												PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
									}
								}
							}
							PlayLeetJumpSound(client);
							if (g_LeetJumpDominating[client] != 3 && g_LeetJumpDominating[client] != 5)
							{
								decl String:buffer[255];
								Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 	
								PlayQuakeSound_Spec(client,buffer);
							}						
						}		
						else
							g_LeetJumpDominating[client]=0;
							
				//strafe sync chat
				if (g_bStrafeSync[client] && g_fJump_Distance[client] >= g_dist_good_bhop)
						PrintToChat(client,"%s", szStrafeSync);		
				
				//new best
				if (g_fPersonalBhopRecord[client] < g_fJump_Distance[client]  &&  !IsFakeClient(client))
				{
					if (g_fPersonalBhopRecord[client] > 0.0)
						PrintToChat(client, "%t", "Jumpstats_BeatBhopBest",MOSSGREEN,WHITE,YELLOW, g_fJump_Distance[client]);
					g_fPersonalBhopRecord[client] = g_fJump_Distance[client];
					db_updateBhopRecord(client);
				}
			}
	}
	PostThinkPost(client, ground_frames);						
}

public PostThinkPost(client, ground_frames)
{
	g_bPlayerJumped[client] = false;
	g_last_ground_frames[client] = ground_frames;		
}