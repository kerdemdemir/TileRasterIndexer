import std;

immutable int gridCount = 120;
immutable int pointCount = 120+1;


struct RasterTileGridIndex
{
    int tileXIndex = -1;
    int tileYIndex = -1;
    int gridXIndex = -1;
    int gridYIndex = -1;

	enum StepResult
	{
		SafeStep = 0,
		EndLine,
	}

	bool opEquals(ref const RasterTileGridIndex rhs)
	{
		return tileXIndex == rhs.tileXIndex && tileYIndex == rhs.tileYIndex && gridXIndex == rhs.gridXIndex && gridYIndex == rhs.gridYIndex;
	}

    int GetArrayIndex()
    {
        return gridYIndex*gridCount+gridXIndex;
    }

	bool DirectionX(ref const RasterTileGridIndex start, ref const RasterTileGridIndex end)
	{
		return start.tileXIndex < end.tileXIndex || ( start.tileXIndex == end.tileXIndex && start.gridXIndex < end.gridXIndex );
	}

	bool DirectionY(ref const RasterTileGridIndex start, ref const RasterTileGridIndex end)
	{
		return start.tileYIndex < end.tileYIndex || ( start.tileYIndex == end.tileYIndex && start.gridYIndex < end.gridYIndex );
	}


	StepResult StepX( bool isEast, int end )
	{
		if ( isEast )
		{
			gridXIndex +=  1;
			return gridXIndex > end ? StepResult.EndLine : StepResult.SafeStep; 
		}
		else 
		{
			gridXIndex -=  1;
			return gridXIndex < end ? StepResult.EndLine : StepResult.SafeStep;
		}	
	}

	void StepY( bool isNorth )
	{
		if ( isNorth )
		{
			gridYIndex +=  1;
		}
		else 
		{
			gridYIndex -=  1;
		}	
	}

    void Next( ref const RasterTileGridIndex start, ref const RasterTileGridIndex end )
    {
		bool isDirectionEast = DirectionX(start,end);
		bool isDirectionNorth = DirectionY(start,end);
		if ( tileXIndex == end.tileXIndex )
		{
			auto stepResult = StepX(isDirectionEast,  end.gridXIndex);
			if ( stepResult == StepResult.EndLine )
			{

				gridXIndex = start.gridXIndex;
				tileXIndex = start.tileXIndex;
				if ( gridYIndex == end.gridYIndex )
				{
					if (tileYIndex == end.tileYIndex)
						return;
					else 
					{
						if (isDirectionNorth)
						{
							tileYIndex += 1;
							gridYIndex = 0;
						}
						else 
						{
							tileYIndex -= 1;
							gridYIndex = gridCount;
						}
						return;
					}
				}

				StepY(isDirectionNorth);
			}
		}
		else 
		{
			auto stepResult = StepX(isDirectionEast, isDirectionEast ? gridCount : 0);
			if ( stepResult == StepResult.EndLine )
			{
				if ( isDirectionEast )
				{
					gridXIndex = 0;
					tileXIndex += 1;
				}
				else 
				{
					gridXIndex = gridCount;
					tileXIndex -= 1;
				}
			}
		}
    }


};

void main()
{

}

unittest  
{
	//SimpleStep
    //  *  * * * *                *  * * * *
	//  *  * * * *     --->       *  * * * *
	//  *  * * * *                *  * * * *
	//  P1 * * * *                * P1 * * *

	RasterTileGridIndex startPoint = RasterTileGridIndex(0, 0, 0, 0 );
	RasterTileGridIndex endPoint = RasterTileGridIndex(0, 0, gridCount, gridCount );

	RasterTileGridIndex p1 = RasterTileGridIndex(0, 0, 0, 0 );
	p1.Next(startPoint, endPoint);
	RasterTileGridIndex expectedP1 = RasterTileGridIndex(0,0,1,0);
	assert(p1==expectedP1);


	// Reverse step because end point is left of startPoint
    //  *  * * * *                *  * * * *
	//  *  * * * *     --->       *  * * * *
	//  *  * * * *                *  * * * *
	//  * P1 * * *                P1 * * * *
	swap(startPoint, endPoint);
	p1.Next(startPoint, endPoint);
	expectedP1 = RasterTileGridIndex(0,0,0,0);
	assert(p1==expectedP1);
}


unittest  
{
	//  Same tile end of X index we need Y index jump 
    //  *  * * * *                *  * * * *
	//  *  * * * *     --->       *  * * * *
	//  *  * * * *               P1  * * * *
	//  *  * * * P1               *  * * * *

	RasterTileGridIndex startPoint = RasterTileGridIndex(0, 0, 0, 0 );
	RasterTileGridIndex endPoint = RasterTileGridIndex(0, 0, gridCount, gridCount );

	RasterTileGridIndex p1 = RasterTileGridIndex(0, 0, gridCount, 0 );
	p1.Next(startPoint, endPoint);
	RasterTileGridIndex expectedP1 = RasterTileGridIndex(0,0,0,1);
	assert(p1==expectedP1);


	// Reverse step because end point is left of startPoint
    //  *  * * * *                *  * * * *
	//  *  * * * *     --->       *  * * * *
	// P1  * * * *                *  * * * *
	//  *  * * * *                *  * * * P1
	swap(startPoint, endPoint);
	p1.Next(startPoint, endPoint);
	expectedP1 = RasterTileGridIndex(0,0,gridCount,0);
	assert(p1==expectedP1);
}

unittest  
{
	//  Going from one end to other within same tile 
    //  *  * * * *                *  * * * P1
	//  *  * * * *     --->       *  * * * *
	//  *  * * * *                *  * * * *
	//  P1  * * * *               *  * * * *

	RasterTileGridIndex startPoint = RasterTileGridIndex(0, 0, 0, 0 );
	RasterTileGridIndex endPoint = RasterTileGridIndex(0, 0, gridCount, gridCount );

	RasterTileGridIndex p1 = startPoint;
	int counter = 0;
	while (p1 != endPoint )
	{
		counter++;
		p1.Next(startPoint, endPoint);
	}	
	assert(p1==endPoint);
	int expectedCount = (gridCount+1)*(gridCount+1) - 1;
	assert(counter==expectedCount);

	//  Going reverse from one end to other within same tile 
    //  *  * * * P1               *  * * * *
	//  *  * * * *     --->       *  * * * *
	//  *  * * * *                *  * * * *
	//  *  * * * *               P1  * * * *
	swap(startPoint, endPoint);
	int counter2 = 0;
	while (p1 != endPoint )
	{
		counter2++;
		p1.Next(startPoint, endPoint);
	}	

	assert(p1==endPoint);
	assert(counter==counter2);
}

unittest  
{
	//  Going one tile to another 

	//       T1                        T2               T1                 T2
    //  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
	//  *  * * * *         |       *  * * * * -->  *  * * * *    |     *  * * * *
	//  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
	//  *  * * * P1        |       *  * * * *      *  * * * *    |     P1  * * * *

	RasterTileGridIndex startPoint = RasterTileGridIndex(0, 0, gridCount, 0 );
	RasterTileGridIndex endPoint = RasterTileGridIndex(1, 0, gridCount, gridCount );
	RasterTileGridIndex p1 = startPoint;
	RasterTileGridIndex p1Copy = p1;
	p1.Next(startPoint, endPoint);
	RasterTileGridIndex expectedP1 = RasterTileGridIndex(1,0,0,0);
	assert(p1==expectedP1);

	//  Coming back I am not gonna make the ascii drawing 
	swap(startPoint, endPoint);
	p1.Next(startPoint, endPoint);
	assert(p1Copy==p1);
}


unittest  
{
	//  Going all the way from one tile to another 

	//       T1                        T2               T1                 T2
    //  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * P1
	//  *  * * * *         |       *  * * * * -->  *  * * * *    |     *  * * * *
	//  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
	// P1 *  * * *         |       *  * * * *      *  * * * *    |     *  * * * *

	RasterTileGridIndex startPoint = RasterTileGridIndex(0, 0, 0, 0 );
	RasterTileGridIndex endPoint = RasterTileGridIndex(1, 0, gridCount, gridCount );
	RasterTileGridIndex p1 = startPoint;

	int counter = 0;
	while (p1 != endPoint )
	{
		counter++;
		p1.Next(startPoint, endPoint);
	}	
	assert(p1==endPoint);
	int expectedCount = (gridCount+1)*(gridCount+1)*2 - 1; // 2 Tiles 
	assert(counter==expectedCount);


	//  Going back all the way from one tile to another 
	swap(startPoint, endPoint);
	int counter2 = 0;
	while (p1 != endPoint )
	{
		counter2++;
		p1.Next(startPoint, endPoint);
	}	
	assert(p1==endPoint);
	assert(counter==counter2);
}


unittest  
{
	//  Going one step from one tile to another tile in Y direction 

	//     T(0,1)                     T(1,1)           T(0,1)                     T(1,1)
    //  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
	//  *  * * * *         |       *  * * * * -->  *  * * * *    |     *  * * * *
	//  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
	//  *  * * * *         |       *  * * * *      P1 * * * *    |     *  * * * *
    // -------------------------------------      -------------------------------------
	//  *  * * * *         |       *  * * * P1     *  * * * *    |     *  * * * * 
    //  *  * * * *         |       *  * * * * -->  *  * * * *    |     *  * * * *
    //  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
    // *  *  * * *         |       *  * * * *      *  * * * *    |     *  * * * *
   //      T(0,0)                    T(1,0)            T(0,0)                    T(1,0)
	RasterTileGridIndex startPoint = RasterTileGridIndex(0, 0, 0, 0 );
	RasterTileGridIndex endPoint = RasterTileGridIndex(1, 1, gridCount, gridCount );
	RasterTileGridIndex p1 = RasterTileGridIndex(1,0,gridCount, gridCount);
	RasterTileGridIndex p1Copy = p1; 

	p1.Next(startPoint, endPoint);
	RasterTileGridIndex expectedP1 = RasterTileGridIndex(0,1,0,0);
	assert(p1==expectedP1);

	//  Coming back I am not gonna make the ascii drawing 
	swap(startPoint, endPoint);
	p1.Next(startPoint, endPoint);
	assert(p1Copy==p1);
}


unittest  
{
	//  Going all the way from one tile to another tile in Y direction 

	//     T(0,1)                     T(1,1)           T(0,1)                     T(1,1)
    //  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * p1
	//  *  * * * *         |       *  * * * * -->  *  * * * *    |     *  * * * *
	//  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
	//  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
    // -------------------------------------      -------------------------------------
	//  *   * * * *         |       *  * * * *     *  * * * *    |     *  * * * * 
    //  *   * * * *         |       *  * * * * -->  *  * * * *    |     *  * * * *
    //  *   * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
    //  p1  * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
   //      T(0,0)                    T(1,0)            T(0,0)                    T(1,0)

	RasterTileGridIndex startPoint = RasterTileGridIndex(0, 0, 0, 0 );
	RasterTileGridIndex endPoint = RasterTileGridIndex(1, 1, gridCount, gridCount );
	RasterTileGridIndex p1 = RasterTileGridIndex(0, 0 , 0,  0); 
	int counter = 0;
	while (p1 != endPoint )
	{
		counter++;
		p1.Next(startPoint, endPoint);
	}	
	assert(p1==endPoint);
	int totalCount = (gridCount+1)*(gridCount+1)*4 - 1; // 2 Tiles 
	assert(counter==totalCount);


	//  Going back all the way from one tile to another 
	swap(startPoint, endPoint);
	int counter2 = 0;
	while (p1 != endPoint )
	{
		counter2++;
		p1.Next(startPoint, endPoint);
	}	
	assert(p1==endPoint);
	assert(counter==counter2);
}


unittest  
{
	//  Going all the way from one tile to another tile in Y direction but not starting from 0,0

	//     T(0,1)                     T(1,1)           T(0,1)                     T(1,1)
    //  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * p1
	//  *  * * * *         |       *  * * * * -->  *  * * * *    |     *  * * * *
	//  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
	//  *  * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
    // -------------------------------------      -------------------------------------
	//  *   * * * *         |       *  * * * *     *  * * * *    |     *  * * * * 
    //  *   * * * *         |       *  * * * * -->  *  * * * *    |     *  * * * *
    //  *  p1 * * *         |       *  * * * *      *  * * * *    |     *  * * * *
    //  *   * * * *         |       *  * * * *      *  * * * *    |     *  * * * *
   //      T(0,0)                    T(1,0)            T(0,0)                    T(1,0)

	RasterTileGridIndex startPoint = RasterTileGridIndex(0, 0, 1,  1 );
	RasterTileGridIndex endPoint = RasterTileGridIndex(1, 1, gridCount-1, gridCount-1 );
	RasterTileGridIndex p1 = startPoint; 
	int counter = 0;
	while (p1 != endPoint )
	{
		counter++;
		p1.Next(startPoint, endPoint);
	}	
	assert(p1==endPoint);
	int totalCount = gridCount*gridCount*4 - 1; // 2 Tiles 
	totalCount -= (2*(gridCount+1)+1);
	assert(counter==totalCount);


	//  Going back all the way from one tile to another 
	swap(startPoint, endPoint);
	int counter2 = 0;
	while (p1 != endPoint )
	{
		counter2++;
		p1.Next(startPoint, endPoint);
	}	
	assert(p1==endPoint);
	assert(counter==counter2);
}