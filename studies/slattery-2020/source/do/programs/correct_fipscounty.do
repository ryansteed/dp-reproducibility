capture program drop correct_fipscounty
program define correct_fipscounty

	qui{

	* MERGE SOME VA CITIES 
		replace fipscounty = 51003 if fipscounty==51540 //Albemarle + Charlottesville, VA
		replace fipscounty = 51005 if fipscounty==51580 //Alleghany + Covington, VA
		replace fipscounty = 51005 if fipscounty==51560 //Alleghany + Covington + Clifton Forge, VA
		replace fipscounty = 51015 if fipscounty==51790 //Augusta, Staunton + Waynesboro, VA
		replace fipscounty = 51015 if fipscounty==51820 //Augusta, Staunton + Waynesboro, VA

		replace fipscounty = 51015 if fipscounty==51830 //Augusta, Staunton + Waynesboro, VA

		replace fipscounty = 51019 if fipscounty==51515 //Bedford + Bedford, VA
		replace fipscounty = 51031 if fipscounty==51680 //Campbell + Lynchburg, VA

		replace fipscounty = 51035 if fipscounty==51640 //Carroll + Galax, VA
		replace fipscounty = 51053 if fipscounty==51570 //Dinwiddie, Colonial Heights + Petersburg, VA
		replace fipscounty = 51053 if fipscounty==51730 //Dinwiddie, Colonial Heights + Petersburg, VA

		replace fipscounty = 51059 if fipscounty==51600 //Fairfax, Fairfax City + Falls Church, VA
		replace fipscounty = 51059 if fipscounty==51610 //Fairfax, Fairfax City + Falls Church, VA

		replace fipscounty = 51069 if fipscounty==51840 //Frederick + Winchester, VA

		replace fipscounty = 51081 if fipscounty==51595 //Greensville + Emporia, VA

		replace fipscounty = 51089 if fipscounty==51690 //Henry + Martinsville, VA
		replace fipscounty = 51095 if fipscounty==51830 //James City + Williamsburg, VA

		replace fipscounty = 51121 if fipscounty==51750 //Montgomery + Radford, VA
		replace fipscounty = 51143 if fipscounty==51590 //Pittsylvania + Danville, VA
		replace fipscounty = 51149 if fipscounty==51670 //Prince George + Hopewell, VA
		replace fipscounty = 51153 if fipscounty==51683 //Prince William, Manassas + Manassas Park, VA
		replace fipscounty = 51153 if fipscounty==51685 //Prince William, Manassas + Manassas Park, VA

		replace fipscounty = 51161 if fipscounty==51775 //Roanoke + Salem, VA
		replace fipscounty = 51163 if fipscounty==51530 //Rockbridge, Buena Vista + Lexington, VA
		replace fipscounty = 51163 if fipscounty==51678 //Rockbridge, Buena Vista + Lexington, VA

		replace fipscounty = 51165 if fipscounty==51660 //Rockingham + Harrisonburg, VA
		replace fipscounty = 51175 if fipscounty==51620 //Southampton + Franklin, VA
		replace fipscounty = 51177 if fipscounty==51630 //Spotsylvania + Fredericksburg, VA
		replace fipscounty = 51191 if fipscounty==51520 //Washington + Bristol, VA
		replace fipscounty = 51195 if fipscounty==51720 //Wise + Norton, VA
		replace fipscounty = 51199 if fipscounty==51735 //York + Poquoson, VA

		* CLEAN UP SOME COUNTIES
		replace fipscounty = 46102 if fipscounty==46113 //Shannon SD becomes Oglala Lakota SD
		replace fipscounty = 02158 if fipscounty==02270 // Wade Hampton Census Area, AK becomes Kusilvak Census Area, AK 
	
	}


end