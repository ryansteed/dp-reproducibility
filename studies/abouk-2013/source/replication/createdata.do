
*create data set of controls
clear


# insheet using shell.dat
### EDIT BY Donna
insheet using shell.dat

tab month, gen(mon)
tab state, gen(st)
tab year, gen(yr)
tab time, gen(t)
gen mon=month

generate pop=0
replace pop=	4661900	if	st1	==1	& year==	2007
replace pop=	683478	if 	st2	==1	& year==	2007
replace pop=	6338755	if	st3	==1	& year==	2007
replace pop=	2834797	if 	st4	==1	& year==	2007
replace pop=	36553215	if	st5	==1	& year==	2007
replace pop=	4939456	if 	st6	==1	& year==	2007
replace pop=	3502309	if	st7	==1	& year==	2007
replace pop=	864764	if 	st8	==1	& year==	2007
replace pop=	588292	if	st9	==1	& year==	2007
replace pop=	18251243	if 	st10	==1	& year==	2007
replace pop=	9544750	if	st11	==1	& year==	2007
replace pop=	1283388	if 	st12	==1	& year==	2007
replace pop=	1499402	if	st13	==1	& year==	2007
replace pop=	12852548	if 	st14	==1	& year==	2007
replace pop=	6345289	if	st15	==1	& year==	2007
replace pop=	2988046	if 	st16	==1	& year==	2007
replace pop=	2775997	if	st17	==1	& year==	2007
replace pop=	4241474	if 	st18	==1	& year==	2007
replace pop=	4293204	if	st19	==1	& year==	2007
replace pop=	1317207	if 	st20	==1	& year==	2007
replace pop=	5618344	if	st21	==1	& year==	2007
replace pop=	6449755	if 	st22	==1	& year==	2007
replace pop=	10071822	if	st23	==1	& year==	2007
replace pop=	5197621	if 	st24	==1	& year==	2007
replace pop=	2918785	if	st25	==1	& year==	2007
replace pop=	5878415	if 	st26	==1	& year==	2007
replace pop=	957861	if	st27	==1	& year==	2007
replace pop=	1774571	if 	st28	==1	& year==	2007
replace pop=	2565382	if	st29	==1	& year==	2007
replace pop=	1315828	if 	st30	==1	& year==	2007
replace pop=	8685920	if	st31	==1	& year==	2007
replace pop=	1969915	if 	st32	==1	& year==	2007
replace pop=	19297729	if	st33	==1	& year==	2007
replace pop=	9061032	if 	st34	==1	& year==	2007
replace pop=	639715	if	st35	==1	& year==	2007
replace pop=	11466917	if 	st36	==1	& year==	2007
replace pop=	3617316	if	st37	==1	& year==	2007
replace pop=	3747455	if 	st38	==1	& year==	2007
replace pop=	12432792	if	st39	==1	& year==	2007
replace pop=	1057832	if 	st40	==1	& year==	2007
replace pop=	4407709	if	st41	==1	& year==	2007
replace pop=	796214	if 	st42	==1	& year==	2007
replace pop=	6156719	if	st43	==1	& year==	2007
replace pop=	23904380	if 	st44	==1	& year==	2007
replace pop=	2645330	if	st45	==1	& year==	2007
replace pop=	621254	if 	st46	==1	& year==	2007
replace pop=	7712091	if	st47	==1	& year==	2007
replace pop=	6468424	if 	st48	==1	& year==	2007
replace pop=	1812035	if	st49	==1	& year==	2007
replace pop=	5601640	if 	st50	==1	& year==	2007
replace pop=	522830	if	st51	==1	& year==	2007
replace pop=	4627851	if 	st1	==1	& year==	2008
replace pop=	686293	if	st2	==1	& year==	2008
replace pop=	6500180	if 	st3	==1	& year==	2008
replace pop=	2855390	if	st4	==1	& year==	2008
replace pop=	36756666	if 	st5	==1	& year==	2008
replace pop=	4861515	if	st6	==1	& year==	2008
replace pop=	3501252	if 	st7	==1	& year==	2008
replace pop=	873092	if	st8	==1	& year==	2008
replace pop=	591833	if 	st9	==1	& year==	2008
replace pop=	18328340	if	st10	==1	& year==	2008
replace pop=	9685744	if 	st11	==1	& year==	2008
replace pop=	1288198	if	st12	==1	& year==	2008
replace pop=	1523816	if 	st13	==1	& year==	2008
replace pop=	12901563	if	st14	==1	& year==	2008
replace pop=	6376792	if 	st15	==1	& year==	2008
replace pop=	3002555	if	st16	==1	& year==	2008
replace pop=	2802134	if 	st17	==1	& year==	2008
replace pop=	4269245	if	st18	==1	& year==	2008
replace pop=	4410796	if 	st19	==1	& year==	2008
replace pop=	1316456	if	st20	==1	& year==	2008
replace pop=	5633597	if 	st21	==1	& year==	2008
replace pop=	6497967	if	st22	==1	& year==	2008
replace pop=	10003422	if 	st23	==1	& year==	2008
replace pop=	5220393	if	st24	==1	& year==	2008
replace pop=	2938618	if 	st25	==1	& year==	2008
replace pop=	5911605	if	st26	==1	& year==	2008
replace pop=	967440	if 	st27	==1	& year==	2008
replace pop=	1783432	if	st28	==1	& year==	2008
replace pop=	2600167	if 	st29	==1	& year==	2008
replace pop=	1315809	if	st30	==1	& year==	2008
replace pop=	8682661	if 	st31	==1	& year==	2008
replace pop=	1984356	if	st32	==1	& year==	2008
replace pop=	19490297	if 	st33	==1	& year==	2008
replace pop=	9222414	if	st34	==1	& year==	2008
replace pop=	641481	if 	st35	==1	& year==	2008
replace pop=	11485910	if	st36	==1	& year==	2008
replace pop=	3642361	if 	st37	==1	& year==	2008
replace pop=	3790060	if	st38	==1	& year==	2008
replace pop=	12448279	if 	st39	==1	& year==	2008
replace pop=	1050788	if	st40	==1	& year==	2008
replace pop=	4479800	if 	st41	==1	& year==	2008
replace pop=	804194	if	st42	==1	& year==	2008
replace pop=	6214888	if 	st43	==1	& year==	2008
replace pop=	24326974	if	st44	==1	& year==	2008
replace pop=	2736424	if 	st45	==1	& year==	2008
replace pop=	621270	if	st46	==1	& year==	2008
replace pop=	7769089	if 	st47	==1	& year==	2008
replace pop=	6549224	if	st48	==1	& year==	2008
replace pop=	1814468	if 	st49	==1	& year==	2008
replace pop=	5627967	if	st50	==1	& year==	2008
replace pop=	532668	if 	st51	==1	& year==	2008
replace pop=	4708708	if	st1	==1	& year==	2009
replace pop=	698473	if 	st2	==1	& year==	2009
replace pop=	6595778	if	st3	==1	& year==	2009
replace pop=	2889450	if 	st4	==1	& year==	2009
replace pop=	36961664	if	st5	==1	& year==	2009
replace pop=	5024748	if 	st6	==1	& year==	2009
replace pop=	3518288	if	st7	==1	& year==	2009
replace pop=	885122	if 	st8	==1	& year==	2009
replace pop=	599657	if	st9	==1	& year==	2009
replace pop=	18537969	if 	st10	==1	& year==	2009
replace pop=	9829211	if	st11	==1	& year==	2009
replace pop=	1295178	if 	st12	==1	& year==	2009
replace pop=	1545801	if	st13	==1	& year==	2009
replace pop=	12910409	if 	st14	==1	& year==	2009
replace pop=	6423113	if	st15	==1	& year==	2009
replace pop=	3007856	if 	st16	==1	& year==	2009
replace pop=	2818747	if	st17	==1	& year==	2009
replace pop=	4314113	if 	st18	==1	& year==	2009
replace pop=	4492076	if	st19	==1	& year==	2009
replace pop=	1318301	if 	st20	==1	& year==	2009
replace pop=	5699478	if	st21	==1	& year==	2009
replace pop=	6593587	if 	st22	==1	& year==	2009
replace pop=	9969727	if	st23	==1	& year==	2009
replace pop=	5266214	if 	st24	==1	& year==	2009
replace pop=	2951996	if	st25	==1	& year==	2009
replace pop=	5987580	if 	st26	==1	& year==	2009
replace pop=	974989	if	st27	==1	& year==	2009
replace pop=	1796619	if 	st28	==1	& year==	2009
replace pop=	2643085	if	st29	==1	& year==	2009
replace pop=	1324575	if 	st30	==1	& year==	2009
replace pop=	8707739	if	st31	==1	& year==	2009
replace pop=	2009671	if 	st32	==1	& year==	2009
replace pop=	19541453	if	st33	==1	& year==	2009
replace pop=	9380884	if 	st34	==1	& year==	2009
replace pop=	646844	if	st35	==1	& year==	2009
replace pop=	11542645	if 	st36	==1	& year==	2009
replace pop=	3687050	if	st37	==1	& year==	2009
replace pop=	3825657	if 	st38	==1	& year==	2009
replace pop=	12604767	if	st39	==1	& year==	2009
replace pop=	1053209	if 	st40	==1	& year==	2009
replace pop=	4561242	if	st41	==1	& year==	2009
replace pop=	812383	if 	st42	==1	& year==	2009
replace pop=	6296254	if	st43	==1	& year==	2009
replace pop=	24782302	if 	st44	==1	& year==	2009
replace pop=	2784572	if	st45	==1	& year==	2009
replace pop=	621760	if 	st46	==1	& year==	2009
replace pop=	7882590	if	st47	==1	& year==	2009
replace pop=	6664195	if 	st48	==1	& year==	2009
replace pop=	1819777	if	st49	==1	& year==	2009
replace pop=	5654774	if 	st50	==1	& year==	2009
replace pop=	544270	if	st51	==1	& year==	2009


replace pop=	4785298	if	st1	==1	&	year==	2010
replace pop=	713985	if 	st2	==1	&	year==	2010
replace pop=	6413737	if	st3	==1	&	year==	2010
replace pop=	2921606	if 	st4	==1	&	year==	2010
replace pop=	37349363	if	st5	==1	&	year==	2010
replace pop=	5049071	if 	st6	==1	&	year==	2010
replace pop=	3577073	if	st7	==1	&	year==	2010
replace pop=	899769	if 	st8	==1	&	year==	2010
replace pop=	604453	if	st9	==1	&	year==	2010
replace pop=	18843326	if 	st10==1	&	year==	2010
replace pop=	9712587	if	st11	==1	&	year==	2010
replace pop=	1363621	if 	st12	==1	&	year==	2010
replace pop=	1571450	if	st13	==1	&	year==	2010
replace pop=	12843166	if 	st14==1	&	year==	2010
replace pop=	6490621	if	st15	==1	&	year==	2010
replace pop=	3049883	if 	st16	==1	&	year==	2010
replace pop=	2859169	if	st17	==1	&	year==	2010
replace pop=	4346266	if 	st18	==1	&	year==	2010
replace pop=	4544228	if	st19	==1	&	year==	2010
replace pop=	1327567	if 	st20	==1	&	year==	2010
replace pop=	5785982	if	st21	==1	&	year==	2010
replace pop=	6557254	if 	st22	==1	&	year==	2010
replace pop=	9877574	if	st23	==1	&	year==	2010
replace pop=	5310584	if 	st24	==1	&	year==	2010
replace pop=	2970036	if	st25	==1	&	year==	2010
replace pop=	5996231	if 	st26	==1	&	year==	2010
replace pop=	990898	if	st27	==1	&	year==	2010
replace pop=	1830429	if 	st28	==1	&	year==	2010
replace pop=	2704642	if	st29	==1	&	year==	2010
replace pop=	1316759	if 	st30	==1	&	year==	2010
replace pop=	8801624	if	st31	==1	&	year==	2010
replace pop=	2065932	if 	st32	==1	&	year==	2010
replace pop=	19392283	if	st33==1	&	year==	2010
replace pop=	9561558	if 	st34==1	&	year==2010
replace pop=	674499	if	st35==1	&	year==2010
replace pop=	11536182	if 	st36==1	&	year==2010
replace pop=	3761702	if	st37==1	&	year==2010
replace pop=	3838957	if 	st38==1	&	year==2010
replace pop=	12709630	if	st39==1	&	year==2010
replace pop=	1052886	if 	st40==1	&	year==2010
replace pop=	4636312	if	st41==1	&	year==2010
replace pop=	816463	if 	st42==1	&	year==2010
replace pop=	6356897	if	st43==1	&	year==2010
replace pop=	25257114	if 	st44==1	&	year==2010
replace pop=	2776469	if	st45==1	&	year==	2010
replace pop=	625960	if 	st46==1	&	year==	2010
replace pop=	8024617	if	st47==1	&	year==	2010
replace pop=	6744496	if 	st48==1	&	year==	2010
replace pop=	1853973	if	st49==1	&	year==	2010
replace pop=	5691047	if 	st50==1	&	year==	2010
replace pop=	564460	if	st51==1	&	year==	2010








*Unemployment
*--------------------
gen unemp=0

replace unemp=	3.3	if	year==	2007	&	mon1	==1	&	st1==1
replace unemp=	3.3	if	year==	2007	&	mon2	==1	&	st1==1
replace unemp=	3.3	if	year==	2007	&	mon3	==1	&	st1==1
replace unemp=	3.3	if	year==	2007	&	mon4	==1	&	st1==1
replace unemp=	3.3	if	year==	2007	&	mon5	==1	&	st1==1
replace unemp=	3.3	if	year==	2007	&	mon6	==1	&	st1==1
replace unemp=	3.4	if	year==	2007	&	mon7	==1	&	st1==1
replace unemp=	3.5	if	year==	2007	&	mon8	==1	&	st1==1
replace unemp=	3.5	if	year==	2007	&	mon9	==1	&	st1==1
replace unemp=	3.6	if	year==	2007	&	mon10	==1	&	st1==1
replace unemp=	3.7	if	year==	2007	&	mon11	==1	&	st1==1
replace unemp=	3.8	if	year==	2007	&	mon12	==1	&	st1==1
replace unemp=	3.9	if	year==	2008	&	mon1	==1	&	st1==1
replace unemp=	4	if	year==	2008	&	mon2	==1	&	st1==1
replace unemp=	4.1	if	year==	2008	&	mon3	==1	&	st1==1
replace unemp=	4.3	if	year==	2008	&	mon4	==1	&	st1==1
replace unemp=	4.5	if	year==	2008	&	mon5	==1	&	st1==1
replace unemp=	4.7	if	year==	2008	&	mon6	==1	&	st1==1
replace unemp=	4.9	if	year==	2008	&	mon7	==1	&	st1==1
replace unemp=	5.2	if	year==	2008	&	mon8	==1	&	st1==1
replace unemp=	5.5	if	year==	2008	&	mon9	==1	&	st1==1
replace unemp=	5.9	if	year==	2008	&	mon10	==1	&	st1==1
replace unemp=	6.5	if	year==	2008	&	mon11	==1	&	st1==1
replace unemp=	7.1	if	year==	2008	&	mon12	==1	&	st1==1
replace unemp=	7.8	if	year==	2009	&	mon1	==1	&	st1==1
replace unemp=	8.5	if	year==	2009	&	mon2	==1	&	st1==1
replace unemp=	9	if	year==	2009	&	mon3	==1	&	st1==1
replace unemp=	9.4	if	year==	2009	&	mon4	==1	&	st1==1
replace unemp=	9.7	if	year==	2009	&	mon5	==1	&	st1==1
replace unemp=	10	if	year==	2009	&	mon6	==1	&	st1==1
replace unemp=	10.2 if	year==	2009	&	mon7	==1	&	st1==1
replace unemp=	10.3 if	year==	2009	&	mon8	==1	&	st1==1
replace unemp=	10.4 if	year==	2009	&	mon9	==1	&	st1==1
replace unemp=	10.4 if	year==	2009	&	mon10	==1	&	st1==1
replace unemp=	10.4 if	year==	2009	&	mon11	==1	&	st1==1
replace unemp=	10.4 if	year==	2009	&	mon12	==1	&	st1==1

replace unemp=	10.3 if	year==	2010	&	mon1	==1	&	st1==1
replace unemp=	10.2 if	year==	2010	&	mon2	==1	&	st1==1
replace unemp=	10	if	year==	2010	&	mon3	==1	&	st1==1
replace unemp=	9.8	if	year==	2010	&	mon4	==1	&	st1==1
replace unemp=	9.5	if	year==	2010	&	mon5	==1	&	st1==1
replace unemp=	9.3 if	year==	2010	&	mon6	==1	&	st1==1
replace unemp=	9.2 if	year==	2010	&	mon7	==1	&	st1==1
replace unemp=	9.1	if	year==	2010	&	mon8	==1	&	st1==1
replace unemp=	9.1	if	year==	2010	&	mon9	==1	&	st1==1
replace unemp=	9.1	if	year==	2010	&	mon10	==1	&	st1==1
replace unemp=	9.1	if	year==	2010	&	mon11	==1	&	st1==1
replace unemp=	9.1	if	year==	2010	&	mon12	==1	&	st1==1


replace unemp=	6.1	if	year==	2007	&	mon1	==1	&	st2==1
replace unemp=	6	if	year==	2007	&	mon2	==1	&	st2==1
replace unemp=	5.9	if	year==	2007	&	mon3	==1	&	st2==1
replace unemp=	5.9	if	year==	2007	&	mon4	==1	&	st2==1
replace unemp=	6	if	year==	2007	&	mon5	==1	&	st2==1
replace unemp=	6	if	year==	2007	&	mon6	==1	&	st2==1
replace unemp=	6.1	if	year==	2007	&	mon7	==1	&	st2==1
replace unemp=	6.1	if	year==	2007	&	mon8	==1	&	st2==1
replace unemp=	6.2	if	year==	2007	&	mon9	==1	&	st2==1
replace unemp=	6.2	if	year==	2007	&	mon10	==1	&	st2==1
replace unemp=	6.2	if	year==	2007	&	mon11	==1	&	st2==1
replace unemp=	6.2	if	year==	2007	&	mon12	==1	&	st2==1
replace unemp=	6.2	if	year==	2008	&	mon1	==1	&	st2==1
replace unemp=	6.2	if	year==	2008	&	mon2	==1	&	st2==1
replace unemp=	6.2	if	year==	2008	&	mon3	==1	&	st2==1
replace unemp=	6.3	if	year==	2008	&	mon4	==1	&	st2==1
replace unemp=	6.3	if	year==	2008	&	mon5	==1	&	st2==1
replace unemp=	6.4	if	year==	2008	&	mon6	==1	&	st2==1
replace unemp=	6.5	if	year==	2008	&	mon7	==1	&	st2==1
replace unemp=	6.5	if	year==	2008	&	mon8	==1	&	st2==1
replace unemp=	6.6	if	year==	2008	&	mon9	==1	&	st2==1
replace unemp=	6.6	if	year==	2008	&	mon10	==1	&	st2==1
replace unemp=	6.7	if	year==	2008	&	mon11	==1	&	st2==1
replace unemp=	6.8	if	year==	2008	&	mon12	==1	&	st2==1
replace unemp=	7	if	year==	2009	&	mon1	==1	&	st2==1
replace unemp=	7.2	if	year==	2009	&	mon2	==1	&	st2==1
replace unemp=	7.4	if	year==	2009	&	mon3	==1	&	st2==1
replace unemp=	7.6	if	year==	2009	&	mon4	==1	&	st2==1
replace unemp=	7.7	if	year==	2009	&	mon5	==1	&	st2==1
replace unemp=	7.9	if	year==	2009	&	mon6	==1	&	st2==1
replace unemp=	8	if	year==	2009	&	mon7	==1	&	st2==1
replace unemp=	8.1	if	year==	2009	&	mon8	==1	&	st2==1
replace unemp=	8.1	if	year==	2009	&	mon9	==1	&	st2==1
replace unemp=	8.2	if	year==	2009	&	mon10	==1	&	st2==1
replace unemp=	8.2	if	year==	2009	&	mon11	==1	&	st2==1
replace unemp=	8.2	if	year==	2009	&	mon12	==1	&	st2==1


replace unemp=	8.2	if	year==	2010	&	mon1	==1	&	st2==1
replace unemp=	8.2	if	year==	2010	&	mon2	==1	&	st2==1
replace unemp=	8.2	if	year==	2010	&	mon3	==1	&	st2==1
replace unemp=	8.1	if	year==	2010	&	mon4	==1	&	st2==1
replace unemp=	8	if	year==	2010	&	mon5	==1	&	st2==1
replace unemp=	7.9	if	year==	2010	&	mon6	==1	&	st2==1
replace unemp=	7.9	if	year==	2010	&	mon7	==1	&	st2==1
replace unemp=	7.9	if	year==	2010	&	mon8	==1	&	st2==1
replace unemp=	7.9	if	year==	2010	&	mon9	==1	&	st2==1
replace unemp=	7.9	if	year==	2010	&	mon10	==1	&	st2==1
replace unemp=	7.9	if	year==	2010	&	mon11	==1	&	st2==1
replace unemp=	7.9	if	year==	2010	&	mon12	==1	&	st2==1

replace unemp=	3.8	if	year==	2007	&	mon1	==1	&	st3==1
replace unemp=	3.7	if	year==	2007	&	mon2	==1	&	st3==1
replace unemp=	3.7	if	year==	2007	&	mon3	==1	&	st3==1
replace unemp=	3.6	if	year==	2007	&	mon4	==1	&	st3==1
replace unemp=	3.6	if	year==	2007	&	mon5	==1	&	st3==1
replace unemp=	3.6	if	year==	2007	&	mon6	==1	&	st3==1
replace unemp=	3.6	if	year==	2007	&	mon7	==1	&	st3==1
replace unemp=	3.7	if	year==	2007	&	mon8	==1	&	st3==1
replace unemp=	3.8	if	year==	2007	&	mon9	==1	&	st3==1
replace unemp=	3.9	if	year==	2007	&	mon10	==1	&	st3==1
replace unemp=	4.1	if	year==	2007	&	mon11	==1	&	st3==1
replace unemp=	4.1	if	year==	2007	&	mon12	==1	&	st3==1
replace unemp=	4.3	if	year==	2008	&	mon1	==1	&	st3==1
replace unemp=	4.5	if	year==	2008	&	mon2	==1	&	st3==1
replace unemp=	4.6	if	year==	2008	&	mon3	==1	&	st3==1
replace unemp=	4.9	if	year==	2008	&	mon4	==1	&	st3==1
replace unemp=	5.2	if	year==	2008	&	mon5	==1	&	st3==1
replace unemp=	5.7	if	year==	2008	&	mon6	==1	&	st3==1
replace unemp=	6	if	year==	2008	&	mon7	==1	&	st3==1
replace unemp=	6.4	if	year==	2008	&	mon8	==1	&	st3==1
replace unemp=	6.7	if	year==	2008	&	mon9	==1	&	st3==1
replace unemp=	7.1	if	year==	2008	&	mon10	==1	&	st3==1
replace unemp=	7.4	if	year==	2008	&	mon11	==1	&	st3==1
replace unemp=	7.8	if	year==	2008	&	mon12	==1	&	st3==1
replace unemp=	8.2	if	year==	2009	&	mon1	==1	&	st3==1
replace unemp=	8.6	if	year==	2009	&	mon2	==1	&	st3==1
replace unemp=	9	if	year==	2009	&	mon3	==1	&	st3==1
replace unemp=	9.3	if	year==	2009	&	mon4	==1	&	st3==1
replace unemp=	9.6	if	year==	2009	&	mon5	==1	&	st3==1
replace unemp=	9.8	if	year==	2009	&	mon6	==1	&	st3==1
replace unemp=	10	if	year==	2009	&	mon7	==1	&	st3==1
replace unemp=	10.2 if	year==	2009	&	mon8	==1	&	st3==1
replace unemp=	10.3 if	year==	2009	&	mon9	==1	&	st3==1
replace unemp=	10.3 if	year==	2009	&	mon10	==1	&	st3==1
replace unemp=	10.4 if	year==	2009	&	mon11	==1	&	st3==1
replace unemp=	10.4 if	year==	2009	&	mon12	==1	&	st3==1

replace unemp=	10.3 if	year==2010	&	mon==1	&	st3==1
replace unemp=	10.2 if	year==2010	&	mon2==1	&	st3==1
replace unemp=	10.1 if	year==2010	&	mon3==1	&	st3==1
replace unemp=	10.1 if	year==2010	&	mon4==1	&	st3==1
replace unemp=	10	if	year==2010	&	mon5==1	&	st3==1
replace unemp=	10	if	year==2010	&	mon6==1	&	st3==1
replace unemp=	9.9	if	year==2010	&	mon7==1	&	st3==1
replace unemp=	9.9	if	year==2010  &	mon8==1	&	st3==1
replace unemp=	9.8	if	year==2010	&	mon9==1	&	st3==1
replace unemp=	9.8	if	year==2010	&	mon10==1 &	st3==1
replace unemp=	9.6	if	year==2010	&	mon11==1 &	st3==1
replace unemp=	9.6	if	year==2010	&	mon12==1 &	st3==1

replace unemp=	5.2	if	year==	2007	&	mon1==1	&	st4==1
replace unemp=	5.1	if	year==	2007	&	mon2==1	&	st4==1
replace unemp=	5.2	if	year==	2007	&	mon3==1	&	st4==1
replace unemp=	5.2	if	year==	2007	&	mon4==1	&	st4==1
replace unemp=	5.2	if	year==	2007	&	mon5==1	&	st4==1
replace unemp=	5.3	if	year==	2007	&	mon6==1	&	st4==1
replace unemp=	5.3	if	year==	2007	&	mon7==1	&	st4==1
replace unemp=	5.4	if	year==	2007	&	mon8==1	&	st4==1
replace unemp=	5.3	if	year==	2007	&	mon9==1	&	st4==1
replace unemp=	5.3	if	year==	2007	&	mon10==1	&	st4==1
replace unemp=	5.2	if	year==	2007	&	mon11==1	&	st4==1
replace unemp=	5.1	if	year==	2007	&	mon12==1	&	st4==1
replace unemp=	5	if	year==	2008	&	mon1==1	&	st4==1
replace unemp=	4.9	if	year==	2008	&	mon2==1	&	st4==1
replace unemp=	4.8	if	year==	2008	&	mon3==1	&	st4==1
replace unemp=	4.8	if	year==	2008	&	mon4==1	&	st4==1
replace unemp=	4.9	if	year==	2008	&	mon5==1	&	st4==1
replace unemp=	5.1	if	year==	2008	&	mon6==1	&	st4==1
replace unemp=	5.2	if	year==	2008	&	mon7==1	&	st4==1
replace unemp=	5.4	if	year==	2008	&	mon8==1	&	st4==1
replace unemp=	5.5	if	year==	2008	&	mon9==1	&	st4==1
replace unemp=	5.8	if	year==	2008	&	mon10==1	&	st4==1
replace unemp=	6	if	year==	2008	&	mon11==1	&	st4==1
replace unemp=	6.3	if	year==	2008	&	mon12==1	&	st4==1
replace unemp=	6.6	if	year==	2009	&	mon1==1	&	st4==1
replace unemp=	6.8	if	year==	2009	&	mon2==1	&	st4==1
replace unemp=	7.1	if	year==	2009	&	mon3==1	&	st4==1
replace unemp=	7.2	if	year==	2009	&	mon4==1	&	st4==1
replace unemp=	7.3	if	year==	2009	&	mon5==1	&	st4==1
replace unemp=	7.4	if	year==	2009	&	mon6==1	&	st4==1
replace unemp=	7.5	if	year==	2009	&	mon7==1	&	st4==1
replace unemp=	7.6	if	year==	2009	&	mon8==1	&	st4==1
replace unemp=	7.6	if	year==	2009	&	mon9==1	&	st4==1
replace unemp=	7.7	if	year==	2009	&	mon10 ==1	&	st4==1
replace unemp=	7.8	if	year==	2009	&	mon11 ==1	&	st4==1
replace unemp=	7.9	if	year==	2009	&	mon12==1	&	st4==1

replace unemp=	8	if	year==	2010	&	mon1==1	&	st4==1
replace unemp=	8	if	year==	2010	&	mon2==1	&	st4==1
replace unemp=	7.9	if	year==	2010	&	mon3==1	&	st4==1
replace unemp=	7.9	if	year==	2010	&	mon4==1	&	st4==1
replace unemp=	7.8	if	year==	2010	&	mon5==1	&	st4==1
replace unemp=	7.8	if	year==	2010	&	mon6==1	&	st4==1
replace unemp=	7.8	if	year==	2010	&	mon7==1	&	st4==1
replace unemp=	7.8	if	year==	2010	&	mon8==1	&	st4==1
replace unemp=	7.8	if	year==	2010	&	mon9==1	&	st4==1
replace unemp=	7.9	if	year==	2010	&	mon10==1	&	st4==1
replace unemp=	7.9	if	year==	2010	&	mon11==1	&	st4==1
replace unemp=	7.9	if	year==	2010	&	mon12==1	&	st4==1

replace unemp=	5	if	year==	2007	&	mon1==1	&	st5==1
replace unemp=	5	if	year==	2007	&	mon2==1	&	st5==1
replace unemp=	5.1	if	year==	2007	&	mon3==1	&	st5==1
replace unemp=	5.2	if	year==	2007	&	mon4==1	&	st5==1
replace unemp=	5.3	if	year==	2007	&	mon5==1	&	st5==1
replace unemp=	5.4	if	year==	2007	&	mon6==1	&	st5==1
replace unemp=	5.5	if	year==	2007	&	mon7==1	&	st5==1
replace unemp=	5.6	if	year==	2007	&	mon8	==1	&	st5==1
replace unemp=	5.7	if	year==	2007	&	mon9	==1	&	st5==1
replace unemp=	5.8	if	year==	2007	&	mon10	==1	&	st5==1
replace unemp=	5.8	if	year==	2007	&	mon11	==1	&	st5==1
replace unemp=	5.9	if	year==	2007	&	mon12	==1	&	st5==1
replace unemp=	5.9	if	year==	2008	&	mon1	==1	&	st5==1
replace unemp=	6	if	year==	2008	&	mon2	==1	&	st5==1
replace unemp=	6.1	if	year==	2008	&	mon3	==1	&	st5==1
replace unemp=	6.3	if	year==	2008	&	mon4	==1	&	st5==1
replace unemp=	6.6	if	year==	2008	&	mon5	==1	&	st5==1
replace unemp=	6.8	if	year==	2008	&	mon6	==1	&	st5==1
replace unemp=	7.1	if	year==	2008	&	mon7	==1	&	st5==1
replace unemp=	7.4	if	year==	2008	&	mon8	==1	&	st5==1
replace unemp=	7.7	if	year==	2008	&	mon9	==1	&	st5==1
replace unemp=	8	if	year==	2008	&	mon10	==1	&	st5==1
replace unemp=	8.5	if	year==	2008	&	mon11	==1	&	st5==1
replace unemp=	9	if	year==	2008	&	mon12	==1	&	st5==1
replace unemp=	9.5	if	year==	2009	&	mon1	==1	&	st5==1
replace unemp=	10	if	year==	2009	&	mon2	==1	&	st5==1
replace unemp=	10.4	if	year==	2009	&	mon3	==1	&	st5==1
replace unemp=	10.8	if	year==	2009	&	mon4	==1	&	st5==1
replace unemp=	11.1	if	year==	2009	&	mon5	==1	&	st5==1
replace unemp=	11.4	if	year==	2009	&	mon6	==1	&	st5==1
replace unemp=	11.6	if	year==	2009	&	mon7	==1	&	st5==1
replace unemp=	11.8	if	year==	2009	&	mon8	==1	&	st5==1
replace unemp=	11.9	if	year==	2009	&	mon9	==1	&	st5==1
replace unemp=	12	if	year==	2009	&	mon10	==1	&	st5==1
replace unemp=	12.1	if	year==	2009	&	mon11	==1	&	st5==1
replace unemp=	12.3	if	year==	2009	&	mon12	==1	&	st5==1

replace unemp=	12.3	if	year==	2010	&	mon1	==1	&	st5==1
replace unemp=	12.4 if	year==	2010	&	mon2	==1	&	st5==1
replace unemp=	12.4	if	year==	2010	&	mon3	==1	&	st5==1
replace unemp=	12.4	if	year==	2010	&	mon4	==1	&	st5==1
replace unemp=	12.3	if	year==	2010	&	mon5	==1	&	st5==1
replace unemp=	12.3	if	year==	2010	&	mon6	==1	&	st5==1
replace unemp=	12.3	if	year==	2010	&	mon7	==1	&	st5==1
replace unemp=	12.3	if	year==	2010	&	mon8	==1	&	st5==1
replace unemp=	12.3	if	year==	2010	&	mon9	==1	&	st5==1
replace unemp=	12.3	if	year==	2010	&	mon10	==1	&	st5==1
replace unemp=	12.3	if	year==	2010	&	mon11	==1	&	st5==1
replace unemp=	12.3	if	year==	2010	&	mon12	==1	&	st5==1


replace unemp=	3.7	if	year==	2007	&	mon1	==1	&	st6==1
replace unemp=	3.6	if	year==	2007	&	mon2	==1	&	st6==1
replace unemp=	3.5	if	year==	2007	&	mon3	==1	&	st6==1
replace unemp=	3.5	if	year==	2007	&	mon4	==1	&	st6==1
replace unemp=	3.5	if	year==	2007	&	mon5	==1	&	st6==1
replace unemp=	3.6	if	year==	2007	&	mon6	==1	&	st6==1
replace unemp=	3.7	if	year==	2007	&	mon7	==1	&	st6==1
replace unemp=	3.8	if	year==	2007	&	mon8	==1	&	st6==1
replace unemp=	3.9	if	year==	2007	&	mon9	==1	&	st6==1
replace unemp=	3.9	if	year==	2007	&	mon10	==1	&	st6==1
replace unemp=	4	if	year==	2007	&	mon11	==1	&	st6==1
replace unemp=	4	if	year==	2007	&	mon12	==1	&	st6==1
replace unemp=	4.1	if	year==	2008	&	mon1	==1	&	st6==1
replace unemp=	4.1	if	year==	2008	&	mon2	==1	&	st6==1
replace unemp=	4.2	if	year==	2008	&	mon3	==1	&	st6==1
replace unemp=	4.3	if	year==	2008	&	mon4	==1	&	st6==1
replace unemp=	4.5	if	year==	2008	&	mon5	==1	&	st6==1
replace unemp=	4.6	if	year==	2008	&	mon6	==1	&	st6==1
replace unemp=	4.8	if	year==	2008	&	mon7	==1	&	st6==1
replace unemp=	4.9	if	year==	2008	&	mon8	==1	&	st6==1
replace unemp=	5.1	if	year==	2008	&	mon9	==1	&	st6==1
replace unemp=	5.4	if	year==	2008	&	mon10	==1	&	st6==1
replace unemp=	5.8	if	year==	2008	&	mon11	==1	&	st6==1
replace unemp=	6.3	if	year==	2008	&	mon12	==1	&	st6==1
replace unemp=	6.8	if	year==	2009	&	mon1	==1	&	st6==1
replace unemp=	7.4	if	year==	2009	&	mon2	==1	&	st6==1
replace unemp=	7.9	if	year==	2009	&	mon3	==1	&	st6==1
replace unemp=	8.3	if	year==	2009	&	mon4	==1	&	st6==1
replace unemp=	8.6	if	year==	2009	&	mon5	==1	&	st6==1
replace unemp=	8.7	if	year==	2009	&	mon6	==1	&	st6==1
replace unemp=	8.6	if	year==	2009	&	mon7	==1	&	st6==1
replace unemp=	8.6	if	year==	2009	&	mon8	==1	&	st6==1
replace unemp=	8.5	if	year==	2009	&	mon9	==1	&	st6==1
replace unemp=	8.5	if	year==	2009	&	mon10	==1	&	st6==1
replace unemp=	8.6	if	year==	2009	&	mon11	==1	&	st6==1
replace unemp=	8.7	if	year==	2009	&	mon12	==1	&	st6==1


replace unemp=	8.9	if	year==	2010	&	mon1	==1	&	st6==1
replace unemp=	9	if	year==	2010	&	mon2	==1	&	st6==1
replace unemp=	9	if	year==	2010	&	mon3	==1	&	st6==1
replace unemp=	9	if	year==	2010	&	mon4	==1	&	st6==1
replace unemp=	8.9	if	year==	2010	&	mon5	==1	&	st6==1
replace unemp=	8.8	if	year==	2010	&	mon6	==1	&	st6==1
replace unemp=	8.8	if	year==	2010	&	mon7	==1	&	st6==1
replace unemp=	8.8	if	year==	2010	&	mon8	==1	&	st6==1
replace unemp=	8.8	if	year==	2010	&	mon9	==1	&	st6==1
replace unemp=	8.9	if	year==	2010	&	mon10	==1	&	st6==1
replace unemp=	8.9	if	year==	2010	&	mon11	==1	&	st6==1
replace unemp=	8.9	if	year==	2010	&	mon12	==1	&	st6==1

replace unemp=	4.4	if	year==	2007	&	mon1	==1	&	st7==1
replace unemp=	4.4	if	year==	2007	&	mon2	==1	&	st7==1
replace unemp=	4.4	if	year==	2007	&	mon3	==1	&	st7==1
replace unemp=	4.4	if	year==	2007	&	mon4	==1	&	st7==1
replace unemp=	4.4	if	year==	2007	&	mon5	==1	&	st7==1
replace unemp=	4.5	if	year==	2007	&	mon6	==1	&	st7==1
replace unemp=	4.5	if	year==	2007	&	mon7	==1	&	st7==1
replace unemp=	4.6	if	year==	2007	&	mon8	==1	&	st7==1
replace unemp=	4.7	if	year==	2007	&	mon9	==1	&	st7==1
replace unemp=	4.8	if	year==	2007	&	mon10	==1	&	st7==1
replace unemp=	4.9	if	year==	2007	&	mon11	==1	&	st7==1
replace unemp=	4.9	if	year==	2007	&	mon12	==1	&	st7==1
replace unemp=	4.9	if	year==	2008	&	mon1	==1	&	st7==1
replace unemp=	5	if	year==	2008	&	mon2	==1	&	st7==1
replace unemp=	5	if	year==	2008	&	mon3	==1	&	st7==1
replace unemp=	5.1	if	year==	2008	&	mon4	==1	&	st7==1
replace unemp=	5.3	if	year==	2008	&	mon5	==1	&	st7==1
replace unemp=	5.5	if	year==	2008	&	mon6	==1	&	st7==1
replace unemp=	5.7	if	year==	2008	&	mon7	==1	&	st7==1
replace unemp=	5.8	if	year==	2008	&	mon8	==1	&	st7==1
replace unemp=	6	if	year==	2008	&	mon9	==1	&	st7==1
replace unemp=	6.2	if	year==	2008	&	mon10	==1	&	st7==1
replace unemp=	6.4	if	year==	2008	&	mon11	==1	&	st7==1
replace unemp=	6.7	if	year==	2008	&	mon12	==1	&	st7==1
replace unemp=	7.1	if	year==	2009	&	mon1	==1	&	st7==1
replace unemp=	7.5	if	year==	2009	&	mon2	==1	&	st7==1
replace unemp=	7.8	if	year==	2009	&	mon3	==1	&	st7==1
replace unemp=	8	if	year==	2009	&	mon4	==1	&	st7==1
replace unemp=	8.2	if	year==	2009	&	mon5	==1	&	st7==1
replace unemp=	8.4	if	year==	2009	&	mon6	==1	&	st7==1
replace unemp=	8.5	if	year==	2009	&	mon7	==1	&	st7==1
replace unemp=	8.6	if	year==	2009	&	mon8	==1	&	st7==1
replace unemp=	8.7	if	year==	2009	&	mon9	==1	&	st7==1
replace unemp=	8.8	if	year==	2009	&	mon10	==1	&	st7==1
replace unemp=	8.9	if	year==	2009	&	mon11	==1	&	st7==1
replace unemp=	9	if	year==	2009	&	mon12	==1	&	st7==1

replace unemp=	9.1	if	year==	2010	&	mon1	==1	&	st7==1
replace unemp=	9.2	if	year==	2010	&	mon2	==1	&	st7==1
replace unemp=	9.2	if	year==	2010	&	mon3	==1	&	st7==1
replace unemp=	9.2 if	year==	2010	&	mon4	==1	&	st7==1
replace unemp=	9.1	if	year==	2010	&	mon5	==1	&	st7==1
replace unemp=	9.1 if	year==	2010	&	mon6	==1	&	st7==1
replace unemp=	9.1	if	year==	2010	&	mon7	==1	&	st7==1
replace unemp=	9.1	if	year==	2010	&	mon8	==1	&	st7==1
replace unemp=	9.1	if	year==	2010	&	mon9	==1	&	st7==1
replace unemp=	9.1	if	year==	2010	&	mon10	==1	&	st7==1
replace unemp=	9.1	if	year==	2010	&	mon11	==1	&	st7==1
replace unemp=	9	if	year==	2010	&	mon12	==1	&	st7==1


replace unemp=	3.4	if	year==	2007	&	mon1	==1	&	st8==1
replace unemp=	3.4	if	year==	2007	&	mon2	==1	&	st8==1
replace unemp=	3.4	if	year==	2007	&	mon3	==1	&	st8==1
replace unemp=	3.5	if	year==	2007	&	mon4	==1	&	st8==1
replace unemp=	3.5	if	year==	2007	&	mon5	==1	&	st8==1
replace unemp=	3.5	if	year==	2007	&	mon6	==1	&	st8==1
replace unemp=	3.5	if	year==	2007	&	mon7	==1	&	st8==1
replace unemp=	3.5	if	year==	2007	&	mon8	==1	&	st8==1
replace unemp=	3.6	if	year==	2007	&	mon9	==1	&	st8==1
replace unemp=	3.6	if	year==	2007	&	mon10	==1	&	st8==1
replace unemp=	3.7	if	year==	2007	&	mon11	==1	&	st8==1
replace unemp=	3.9	if	year==	2007	&	mon12	==1	&	st8==1
replace unemp=	3.9	if	year==	2008	&	mon1	==1	&	st8==1
replace unemp=	3.9	if	year==	2008	&	mon2	==1	&	st8==1
replace unemp=	4	if	year==	2008	&	mon3	==1	&	st8==1
replace unemp=	4.1	if	year==	2008	&	mon4	==1	&	st8==1
replace unemp=	4.4	if	year==	2008	&	mon5	==1	&	st8==1
replace unemp=	4.7	if	year==	2008	&	mon6	==1	&	st8==1
replace unemp=	5	if	year==	2008	&	mon7	==1	&	st8==1
replace unemp=	5.3	if	year==	2008	&	mon8	==1	&	st8==1
replace unemp=	5.5	if	year==	2008	&	mon9	==1	&	st8==1
replace unemp=	5.9	if	year==	2008	&	mon10	==1	&	st8==1
replace unemp=	6.2	if	year==	2008	&	mon11	==1	&	st8==1
replace unemp=	6.6	if	year==	2008	&	mon12	==1	&	st8==1
replace unemp=	7	if	year==	2009	&	mon1	==1	&	st8==1
replace unemp=	7.4	if	year==	2009	&	mon2	==1	&	st8==1
replace unemp=	7.6	if	year==	2009	&	mon3	==1	&	st8==1
replace unemp=	7.8	if	year==	2009	&	mon4	==1	&	st8==1
replace unemp=	8	if	year==	2009	&	mon5	==1	&	st8==1
replace unemp=	8.1	if	year==	2009	&	mon6	==1	&	st8==1
replace unemp=	8.2	if	year==	2009	&	mon7	==1	&	st8==1
replace unemp=	8.2	if	year==	2009	&	mon8	==1	&	st8==1
replace unemp=	8.3	if	year==	2009	&	mon9	==1	&	st8==1
replace unemp=	8.5	if	year==	2009	&	mon10	==1	&	st8==1
replace unemp=	8.5	if	year==	2009	&	mon11	==1	&	st8==1
replace unemp=	8.7	if	year==	2009	&	mon12	==1	&	st8==1


replace unemp=	8.8	if	year==	2010	&	mon1	==1	&	st8==1
replace unemp=	8.7	if	year==	2010	&	mon2	==1	&	st8==1
replace unemp=	8.6	if	year==	2010	&	mon3	==1	&	st8==1
replace unemp=	8.5	if	year==	2010	&	mon4	==1	&	st8==1
replace unemp=	8.4	if	year==	2010	&	mon5	==1	&	st8==1
replace unemp=	8.3	if	year==	2010	&	mon6	==1	&	st8==1
replace unemp=	8.3	if	year==	2010	&	mon7	==1	&	st8==1
replace unemp=	8.3	if	year==	2010	&	mon8	==1	&	st8==1
replace unemp=	8.3	if	year==	2010	&	mon9	==1	&	st8==1
replace unemp=	8.4	if	year==	2010	&	mon10	==1	&	st8==1
replace unemp=	8.4	if	year==	2010	&	mon11	==1	&	st8==1
replace unemp=	8.5	if	year==	2010	&	mon12	==1	&	st8==1


replace unemp=	5.5	if	year==	2007	&	mon1	==1	&	st9==1
replace unemp=	5.4	if	year==	2007	&	mon2	==1	&	st9==1
replace unemp=	5.4	if	year==	2007	&	mon3	==1	&	st9==1
replace unemp=	5.4	if	year==	2007	&	mon4	==1	&	st9==1
replace unemp=	5.4	if	year==	2007	&	mon5	==1	&	st9==1
replace unemp=	5.4	if	year==	2007	&	mon6	==1	&	st9==1
replace unemp=	5.4	if	year==	2007	&	mon7	==1	&	st9==1
replace unemp=	5.4	if	year==	2007	&	mon8	==1	&	st9==1
replace unemp=	5.5	if	year==	2007	&	mon9	==1	&	st9==1
replace unemp=	5.5	if	year==	2007	&	mon10	==1	&	st9==1
replace unemp=	5.5	if	year==	2007	&	mon11	==1	&	st9==1
replace unemp=	5.5	if	year==	2007	&	mon12	==1	&	st9==1
replace unemp=	5.6	if	year==	2008	&	mon1	==1	&	st9==1
replace unemp=	5.6	if	year==	2008	&	mon2	==1	&	st9==1
replace unemp=	5.7	if	year==	2008	&	mon3	==1	&	st9==1
replace unemp=	5.9	if	year==	2008	&	mon4	==1	&	st9==1
replace unemp=	6.1	if	year==	2008	&	mon5	==1	&	st9==1
replace unemp=	6.4	if	year==	2008	&	mon6	==1	&	st9==1
replace unemp=	6.6	if	year==	2008	&	mon7	==1	&	st9==1
replace unemp=	6.9	if	year==	2008	&	mon8	==1	&	st9==1
replace unemp=	7.1	if	year==	2008	&	mon9	==1	&	st9==1
replace unemp=	7.4	if	year==	2008	&	mon10	==1	&	st9==1
replace unemp=	7.7	if	year==	2008	&	mon11	==1	&	st9==1
replace unemp=	8	if	year==	2008	&	mon12	==1	&	st9==1
replace unemp=	8.3	if	year==	2009	&	mon1	==1	&	st9==1
replace unemp=	8.6	if	year==	2009	&	mon2	==1	&	st9==1
replace unemp=	8.9	if	year==	2009	&	mon3	==1	&	st9==1
replace unemp=	9.1	if	year==	2009	&	mon4	==1	&	st9==1
replace unemp=	9.4	if	year==	2009	&	mon5	==1	&	st9==1
replace unemp=	9.6	if	year==	2009	&	mon6	==1	&	st9==1
replace unemp=	9.8	if	year==	2009	&	mon7	==1	&	st9==1
replace unemp=	10	if	year==	2009	&	mon8	==1	&	st9==1
replace unemp=	10.2	if	year==	2009	&	mon9	==1	&	st9==1
replace unemp=	10.3	if	year==	2009	&	mon10	==1	&	st9==1
replace unemp=	10.3	if	year==	2009	&	mon11	==1	&	st9==1
replace unemp=	10.4	if	year==	2009	&	mon12	==1	&	st9==1


replace unemp=	10.3	if	year==	2010	&	mon1	==1	&	st9==1
replace unemp=	10.3	if	year==	2010	&	mon2	==1	&	st9==1
replace unemp=	10.1	if	year==	2010	&	mon3	==1	&	st9==1
replace unemp=	10	if	year==	2010	&	mon4	==1	&	st9==1
replace unemp=	9.9	if	year==	2010	&	mon5	==1	&	st9==1
replace unemp=	9.8	if	year==	2010	&	mon6	==1	&	st9==1
replace unemp=	9.8	if	year==	2010	&	mon7	==1	&	st9==1
replace unemp=	9.8	if	year==	2010	&	mon8	==1	&	st9==1
replace unemp=	9.7	if	year==	2010	&	mon9	==1	&	st9==1
replace unemp=	9.7	if	year==	2010	&	mon10	==1	&	st9==1
replace unemp=	9.7 if	year==	2010	&	mon11	==1	&	st9==1
replace unemp=	9.6	if	year==	2010	&	mon12	==1	&	st9==1


replace unemp=	3.4	if	year==	2007	&	mon1	==1	&	st10==1
replace unemp=	3.4	if	year==	2007	&	mon2	==1	&	st10==1
replace unemp=	3.5	if	year==	2007	&	mon3	==1	&	st10==1
replace unemp=	3.6	if	year==	2007	&	mon4	==1	&	st10==1
replace unemp=	3.7	if	year==	2007	&	mon5	==1	&	st10==1
replace unemp=	3.8	if	year==	2007	&	mon6	==1	&	st10==1
replace unemp=	4	if	year==	2007	&	mon7	==1	&	st10==1
replace unemp=	4.1	if	year==	2007	&	mon8	==1	&	st10==1
replace unemp=	4.2	if	year==	2007	&	mon9	==1	&	st10==1
replace unemp=	4.4	if	year==	2007	&	mon10	==1	&	st10==1
replace unemp=	4.5	if	year==	2007	&	mon11	==1	&	st10==1
replace unemp=	4.6	if	year==	2007	&	mon12	==1	&	st10==1
replace unemp=	4.8	if	year==	2008	&	mon1	==1	&	st10==1
replace unemp=	4.9	if	year==	2008	&	mon2	==1	&	st10==1
replace unemp=	5.1	if	year==	2008	&	mon3	==1	&	st10==1
replace unemp=	5.4	if	year==	2008	&	mon4	==1	&	st10==1
replace unemp=	5.7	if	year==	2008	&	mon5	==1	&	st10==1
replace unemp=	5.9	if	year==	2008	&	mon6	==1	&	st10==1
replace unemp=	6.2	if	year==	2008	&	mon7	==1	&	st10==1
replace unemp=	6.5	if	year==	2008	&	mon8	==1	&	st10==1
replace unemp=	6.8	if	year==	2008	&	mon9	==1	&	st10==1
replace unemp=	7.2	if	year==	2008	&	mon10	==1	&	st10==1
replace unemp=	7.6	if	year==	2008	&	mon11	==1	&	st10==1
replace unemp=	8.1	if	year==	2008	&	mon12	==1	&	st10==1
replace unemp=	8.6	if	year==	2009	&	mon1	==1	&	st10==1
replace unemp=	9.1	if	year==	2009	&	mon2	==1	&	st10==1
replace unemp=	9.5	if	year==	2009	&	mon3	==1	&	st10==1
replace unemp=	9.8	if	year==	2009	&	mon4	==1	&	st10==1
replace unemp=	10	if	year==	2009	&	mon5	==1	&	st10==1
replace unemp=	10.1	if	year==	2009	&	mon6	==1	&	st10==1
replace unemp=	10.2	if	year==	2009	&	mon7	==1	&	st10==1
replace unemp=	10.3	if	year==	2009	&	mon8	==1	&	st10==1
replace unemp=	10.5	if	year==	2009	&	mon9	==1	&	st10==1
replace unemp=	10.8	if	year==	2009	&	mon10	==1	&	st10==1
replace unemp=	11	if	year==	2009	&	mon11	==1	&	st10==1
replace unemp=	11.2	if	year==	2009	&	mon12	==1	&	st10==1


replace unemp=	11.3	if	year==	2010	&	mon1	==1	&	st10==1
replace unemp=	11.4	if	year==	2010	&	mon2	==1	&	st10==1
replace unemp=	11.4	if	year==	2010	&	mon3	==1	&	st10==1
replace unemp=	11.4	if	year==	2010	&	mon4	==1	&	st10==1
replace unemp=	11.3	if	year==	2010	&	mon5	==1	&	st10==1
replace unemp=	11.2	if	year==	2010	&	mon6	==1	&	st10==1
replace unemp=	11.1	if	year==	2010	&	mon7	==1	&	st10==1
replace unemp=	11.2	if	year==	2010	&	mon8	==1	&	st10==1
replace unemp=	11.3	if	year==	2010	&	mon9	==1	&	st10==1
replace unemp=	11.5	if	year==	2010	&	mon10	==1	&	st10==1
replace unemp=	11.7	if	year==	2010	&	mon11	==1	&	st10==1
replace unemp=	11.9	if	year==	2010	&	mon12	==1	&	st10==1

replace unemp=	4.5	if	year==	2007	&	mon1	==1	&	st11==1
replace unemp=	4.4	if	year==	2007	&	mon2	==1	&	st11==1
replace unemp=	4.4	if	year==	2007	&	mon3	==1	&	st11==1
replace unemp=	4.4	if	year==	2007	&	mon4	==1	&	st11==1
replace unemp=	4.5	if	year==	2007	&	mon5	==1	&	st11==1
replace unemp=	4.6	if	year==	2007	&	mon6	==1	&	st11==1
replace unemp=	4.7	if	year==	2007	&	mon7	==1	&	st11==1
replace unemp=	4.7	if	year==	2007	&	mon8	==1	&	st11==1
replace unemp=	4.8	if	year==	2007	&	mon9	==1	&	st11==1
replace unemp=	4.9	if	year==	2007	&	mon10	==1	&	st11==1
replace unemp=	5	if	year==	2007	&	mon11	==1	&	st11==1
replace unemp=	5.2	if	year==	2007	&	mon12	==1	&	st11==1
replace unemp=	5.2	if	year==	2008	&	mon1	==1	&	st11==1
replace unemp=	5.3	if	year==	2008	&	mon2	==1	&	st11==1
replace unemp=	5.4	if	year==	2008	&	mon3	==1	&	st11==1
replace unemp=	5.5	if	year==	2008	&	mon4	==1	&	st11==1
replace unemp=	5.9	if	year==	2008	&	mon5	==1	&	st11==1
replace unemp=	6.1	if	year==	2008	&	mon6	==1	&	st11==1
replace unemp=	6.4	if	year==	2008	&	mon7	==1	&	st11==1
replace unemp=	6.6	if	year==	2008	&	mon8	==1	&	st11==1
replace unemp=	6.9	if	year==	2008	&	mon9	==1	&	st11==1
replace unemp=	7.2	if	year==	2008	&	mon10	==1	&	st11==1
replace unemp=	7.6	if	year==	2008	&	mon11	==1	&	st11==1
replace unemp=	8.1	if	year==	2008	&	mon12	==1	&	st11==1
replace unemp=	8.5	if	year==	2009	&	mon1	==1	&	st11==1
replace unemp=	8.8	if	year==	2009	&	mon2	==1	&	st11==1
replace unemp=	9.1	if	year==	2009	&	mon3	==1	&	st11==1
replace unemp=	9.3	if	year==	2009	&	mon4	==1	&	st11==1
replace unemp=	9.6	if	year==	2009	&	mon5	==1	&	st11==1
replace unemp=	9.8	if	year==	2009	&	mon6	==1	&	st11==1
replace unemp=	10	if	year==	2009	&	mon7	==1	&	st11==1
replace unemp=	10.2	if	year==	2009	&	mon8	==1	&	st11==1
replace unemp=	10.3	if	year==	2009	&	mon9	==1	&	st11==1
replace unemp=	10.4	if	year==	2009	&	mon10	==1	&	st11==1
replace unemp=	10.4	if	year==	2009	&	mon11	==1	&	st11==1
replace unemp=	10.4	if	year==	2009	&	mon12	==1	&	st11==1

replace unemp=	10.4	if	year==	2010	&	mon1	==1	&	st11==1
replace unemp=	10.3	if	year==	2010	&	mon2	==1	&	st11==1
replace unemp= 10.2	if	year==	2010	&	mon3	==1	&	st11==1
replace unemp=	10.1	if	year==	2010	&	mon4	==1	&	st11==1
replace unemp=	10	if	year==	2010	&	mon5	==1	&	st11==1
replace unemp=	10	if	year==	2010	&	mon6	==1	&	st11==1
replace unemp=	10.1	if	year==	2010	&	mon7	==1	&	st11==1
replace unemp=	10.2	if	year==	2010	&	mon8	==1	&	st11==1
replace unemp=	10.2	if	year==	2010	&	mon9	==1	&	st11==1
replace unemp=	10.3	if	year==	2010	&	mon10	==1	&	st11==1
replace unemp=	10.4	if	year==	2010	&	mon11	==1	&	st11==1
replace unemp=	10.4	if	year==	2010	&	mon12	==1	&	st11==1


replace unemp=	2.4	if	year==	2007	&	mon1	==1	&	st12==1
replace unemp=	2.4	if	year==	2007	&	mon2	==1	&	st12==1
replace unemp=	2.4	if	year==	2007	&	mon3	==1	&	st12==1
replace unemp=	2.5	if	year==	2007	&	mon4	==1	&	st12==1
replace unemp=	2.5	if	year==	2007	&	mon5	==1	&	st12==1
replace unemp=	2.6	if	year==	2007	&	mon6	==1	&	st12==1
replace unemp=	2.6	if	year==	2007	&	mon7	==1	&	st12==1
replace unemp=	2.7	if	year==	2007	&	mon8	==1	&	st12==1
replace unemp=	2.8	if	year==	2007	&	mon9	==1	&	st12==1
replace unemp=	2.9	if	year==	2007	&	mon10	==1	&	st12==1
replace unemp=	2.9	if	year==	2007	&	mon11	==1	&	st12==1
replace unemp=	3	if	year==	2007	&	mon12	==1	&	st12==1
replace unemp=	3	if	year==	2008	&	mon1	==1	&	st12==1
replace unemp=	3.1	if	year==	2008	&	mon2	==1	&	st12==1
replace unemp=	3.2	if	year==	2008	&	mon3	==1	&	st12==1
replace unemp=	3.4	if	year==	2008	&	mon4	==1	&	st12==1
replace unemp=	3.6	if	year==	2008	&	mon5	==1	&	st12==1
replace unemp=	3.8	if	year==	2008	&	mon6	==1	&	st12==1
replace unemp=	4.1	if	year==	2008	&	mon7	==1	&	st12==1
replace unemp=	4.3	if	year==	2008	&	mon8	==1	&	st12==1
replace unemp=	4.6	if	year==	2008	&	mon9	==1	&	st12==1
replace unemp=	4.9	if	year==	2008	&	mon10	==1	&	st12==1
replace unemp=	5.2	if	year==	2008	&	mon11	==1	&	st12==1
replace unemp=	5.6	if	year==	2008	&	mon12	==1	&	st12==1
replace unemp=	6	if	year==	2009	&	mon1	==1	&	st12==1
replace unemp=	6.4	if	year==	2009	&	mon2	==1	&	st12==1
replace unemp=	6.6	if	year==	2009	&	mon3	==1	&	st12==1
replace unemp=	6.8	if	year==	2009	&	mon4	==1	&	st12==1
replace unemp=	6.9	if	year==	2009	&	mon5	==1	&	st12==1
replace unemp=	7	if	year==	2009	&	mon6	==1	&	st12==1
replace unemp=	7	if	year==	2009	&	mon7	==1	&	st12==1
replace unemp=	7	if	year==	2009	&	mon8	==1	&	st12==1
replace unemp=	7	if	year==	2009	&	mon9	==1	&	st12==1
replace unemp=	7	if	year==	2009	&	mon10	==1	&	st12==1
replace unemp=	7	if	year==	2009	&	mon11	==1	&	st12==1
replace unemp=	6.9	if	year==	2009	&	mon12	==1	&	st12==1

replace unemp=	6.9	if	year==	2010	&	mon1	==1	&	st12==1
replace unemp=	6.8	if	year==	2010	&	mon2	==1	&	st12==1
replace unemp=	6.8	if	year==	2010	&	mon3	==1	&	st12==1
replace unemp=	6.7	if	year==	2010	&	mon4	==1	&	st12==1
replace unemp=	6.6	if	year==	2010	&	mon5	==1	&	st12==1
replace unemp=	6.6	if	year==	2010	&	mon6	==1	&	st12==1
replace unemp=	6.6	if	year==	2010	&	mon7	==1	&	st12==1
replace unemp=	6.6	if	year==	2010	&	mon8	==1	&	st12==1
replace unemp=	6.5	if	year==	2010	&	mon9	==1	&	st12==1
replace unemp=	6.5	if	year==	2010	&	mon10	==1	&	st12==1
replace unemp=	6.4	if	year==	2010	&	mon11	==1	&	st12==1
replace unemp=	6.3	if	year==	2010	&	mon12	==1	&	st12==1



replace unemp=	2.7	if	year==	2007	&	mon1	==1	&	st13==1
replace unemp=	2.7	if	year==	2007	&	mon2	==1	&	st13==1
replace unemp=	2.7	if	year==	2007	&	mon3	==1	&	st13==1
replace unemp=	2.7	if	year==	2007	&	mon4	==1	&	st13==1
replace unemp=	2.7	if	year==	2007	&	mon5	==1	&	st13==1
replace unemp=	2.8	if	year==	2007	&	mon6	==1	&	st13==1
replace unemp=	2.8	if	year==	2007	&	mon7	==1	&	st13==1
replace unemp=	2.9	if	year==	2007	&	mon8	==1	&	st13==1
replace unemp=	3	if	year==	2007	&	mon9	==1	&	st13==1
replace unemp=	3.1	if	year==	2007	&	mon10	==1	&	st13==1
replace unemp=	3.2	if	year==	2007	&	mon11	==1	&	st13==1
replace unemp=	3.3	if	year==	2007	&	mon12	==1	&	st13==1
replace unemp=	3.5	if	year==	2008	&	mon1	==1	&	st13==1
replace unemp=	3.6	if	year==	2008	&	mon2	==1	&	st13==1
replace unemp=	3.8	if	year==	2008	&	mon3	==1	&	st13==1
replace unemp=	4	if	year==	2008	&	mon4	==1	&	st13==1
replace unemp=	4.3	if	year==	2008	&	mon5	==1	&	st13==1
replace unemp=	4.6	if	year==	2008	&	mon6	==1	&	st13==1
replace unemp=	4.9	if	year==	2008	&	mon7	==1	&	st13==1
replace unemp=	5.1	if	year==	2008	&	mon8	==1	&	st13==1
replace unemp=	5.4	if	year==	2008	&	mon9	==1	&	st13==1
replace unemp=	5.7	if	year==	2008	&	mon10	==1	&	st13==1
replace unemp=	5.9	if	year==	2008	&	mon11	==1	&	st13==1
replace unemp=	6.2	if	year==	2008	&	mon12	==1	&	st13==1
replace unemp=	6.4	if	year==	2009	&	mon1	==1	&	st13==1
replace unemp=	6.7	if	year==	2009	&	mon2	==1	&	st13==1
replace unemp=	6.9	if	year==	2009	&	mon3	==1	&	st13==1
replace unemp=	7.1	if	year==	2009	&	mon4	==1	&	st13==1
replace unemp=	7.3	if	year==	2009	&	mon5	==1	&	st13==1
replace unemp=	7.6	if	year==	2009	&	mon6	==1	&	st13==1
replace unemp=	7.9	if	year==	2009	&	mon7	==1	&	st13==1
replace unemp=	8.1	if	year==	2009	&	mon8	==1	&	st13==1
replace unemp=	8.3	if	year==	2009	&	mon9	==1	&	st13==1
replace unemp=	8.5	if	year==	2009	&	mon10	==1	&	st13==1
replace unemp=	8.7	if	year==	2009	&	mon11	==1	&	st13==1
replace unemp=	8.8	if	year==	2009	&	mon12	==1	&	st13==1

replace unemp=	8.9	if	year==	2010	&	mon1	==1	&	st13==1
replace unemp=	9	if	year==	2010	&	mon2	==1	&	st13==1
replace unemp=	9	if	year==	2010	&	mon3	==1	&	st13==1
replace unemp=	9.1	if	year==	2010	&	mon4	==1	&	st13==1
replace unemp=	9.2	if	year==	2010	&	mon5	==1	&	st13==1
replace unemp=	9.3	if	year==	2010	&	mon6	==1	&	st13==1
replace unemp=	9.4	if	year==	2010	&	mon7	==1	&	st13==1
replace unemp=	9.4	if	year==	2010	&	mon8	==1	&	st13==1
replace unemp=	9.5	if	year==	2010	&	mon9	==1	&	st13==1
replace unemp=	9.6	if	year==	2010	&	mon10	==1	&	st13==1
replace unemp=	9.6	if	year==	2010	&	mon11	==1	&	st13==1
replace unemp=	9.7	if	year==	2010	&	mon12	==1	&	st13==1


replace unemp=	4.8	if	year==	2007	&	mon1	==1	&	st14==1
replace unemp=	4.9	if	year==	2007	&	mon2	==1	&	st14==1
replace unemp=	5	if	year==	2007	&	mon3	==1	&	st14==1
replace unemp=	5.1	if	year==	2007	&	mon4	==1	&	st14==1
replace unemp=	5.2	if	year==	2007	&	mon5	==1	&	st14==1
replace unemp=	5.3	if	year==	2007	&	mon6	==1	&	st14==1
replace unemp=	5.4	if	year==	2007	&	mon7	==1	&	st14==1
replace unemp=	5.6	if	year==	2007	&	mon8	==1	&	st14==1
replace unemp=	5.7	if	year==	2007	&	mon9	==1	&	st14==1
replace unemp=	5.8	if	year==	2007	&	mon10	==1	&	st14==1
replace unemp=	5.8	if	year==	2007	&	mon11	==1	&	st14==1
replace unemp=	5.8	if	year==	2007	&	mon12	==1	&	st14==1
replace unemp=	5.8	if	year==	2008	&	mon1	==1	&	st14==1
replace unemp=	5.8	if	year==	2008	&	mon2	==1	&	st14==1
replace unemp=	5.9	if	year==	2008	&	mon3	==1	&	st14==1
replace unemp=	6.1	if	year==	2008	&	mon4	==1	&	st14==1
replace unemp=	6.4	if	year==	2008	&	mon5	==1	&	st14==1
replace unemp=	6.6	if	year==	2008	&	mon6	==1	&	st14==1
replace unemp=	6.9	if	year==	2008	&	mon7	==1	&	st14==1
replace unemp=	7.1	if	year==	2008	&	mon8	==1	&	st14==1
replace unemp=	7.3	if	year==	2008	&	mon9	==1	&	st14==1
replace unemp=	7.4	if	year==	2008	&	mon10	==1	&	st14==1
replace unemp=	7.5	if	year==	2008	&	mon11	==1	&	st14==1
replace unemp=	7.8	if	year==	2008	&	mon12	==1	&	st14==1
replace unemp=	8.1	if	year==	2009	&	mon1	==1	&	st14==1
replace unemp=	8.4	if	year==	2009	&	mon2	==1	&	st14==1
replace unemp=	8.8	if	year==	2009	&	mon3	==1	&	st14==1
replace unemp=	9.2	if	year==	2009	&	mon4	==1	&	st14==1
replace unemp=	9.6	if	year==	2009	&	mon5	==1	&	st14==1
replace unemp=	10.1	if	year==	2009	&	mon6	==1	&	st14==1
replace unemp=	10.5	if	year==	2009	&	mon7	==1	&	st14==1
replace unemp=	10.8	if	year==	2009	&	mon8	==1	&	st14==1
replace unemp=	11.1	if	year==	2009	&	mon9	==1	&	st14==1
replace unemp=	11.3	if	year==	2009	&	mon10	==1	&	st14==1
replace unemp=	11.4	if	year==	2009	&	mon11	==1	&	st14==1
replace unemp=	11.3	if	year==	2009	&	mon12	==1	&	st14==1


replace unemp=	11.2		if	year==	2010	&	mon1	==1	&	st14==1
replace unemp=	11.1		if	year==	2010	&	mon2	==1	&	st14==1
replace unemp=	10.9		if	year==  2010  	&	mon3	==1	&	st14==1
replace unemp=	10.7		if	year==	2010	&	mon4	==1	&	st14==1
replace unemp=	10.5		if	year==	2010	&	mon5	==1	&	st14==1
replace unemp=	10.4	if	year==	2010	&	mon6	==1	&	st14==1
replace unemp=	10.3	if	year==	2010	&	mon7	==1	&	st14==1
replace unemp=	10.2	if	year==	2010	&	mon8	==1	&	st14==1
replace unemp=	10.1	if	year==	2010	&	mon9	==1	&	st14==1
replace unemp=	10 		if	year==	2010	&	mon10	==1	&	st14==1
replace unemp=	9.9		if	year==	2010	&	mon11	==1	&	st14==1
replace unemp=	9.7		if	year==	2010	&	mon12	==1	&	st14==1


replace unemp=	4.6	if	year==	2007	&	mon1	==1	&	st15==1
replace unemp=	4.6	if	year==	2007	&	mon2	==1	&	st15==1
replace unemp=	4.6	if	year==	2007	&	mon3	==1	&	st15==1
replace unemp=	4.5	if	year==	2007	&	mon4	==1	&	st15==1
replace unemp=	4.5	if	year==	2007	&	mon5	==1	&	st15==1
replace unemp=	4.5	if	year==	2007	&	mon6	==1	&	st15==1
replace unemp=	4.6	if	year==	2007	&	mon7	==1	&	st15==1
replace unemp=	4.6	if	year==	2007	&	mon8	==1	&	st15==1
replace unemp=	4.7	if	year==	2007	&	mon9	==1	&	st15==1
replace unemp=	4.7	if	year==	2007	&	mon10	==1	&	st15==1
replace unemp=	4.7	if	year==	2007	&	mon11	==1	&	st15==1
replace unemp=	4.6	if	year==	2007	&	mon12	==1	&	st15==1
replace unemp=	4.7	if	year==	2008	&	mon1	==1	&	st15==1
replace unemp=	4.8	if	year==	2008	&	mon2	==1	&	st15==1
replace unemp=	4.9	if	year==	2008	&	mon3	==1	&	st15==1
replace unemp=	5.2	if	year==	2008	&	mon4	==1	&	st15==1
replace unemp=	5.3	if	year==	2008	&	mon5	==1	&	st15==1
replace unemp=	5.6	if	year==	2008	&	mon6	==1	&	st15==1
replace unemp=	5.8	if	year==	2008	&	mon7	==1	&	st15==1
replace unemp=	6.1	if	year==	2008	&	mon8	==1	&	st15==1
replace unemp=	6.4	if	year==	2008	&	mon9	==1	&	st15==1
replace unemp=	6.9	if	year==	2008	&	mon10	==1	&	st15==1
replace unemp=	7.5	if	year==	2008	&	mon11	==1	&	st15==1
replace unemp=	8.2	if	year==	2008	&	mon12	==1	&	st15==1
replace unemp=	9	if	year==	2009	&	mon1	==1	&	st15==1
replace unemp=	9.6	if	year==	2009	&	mon2	==1	&	st15==1
replace unemp=	10.2	if	year==	2009	&	mon3	==1	&	st15==1
replace unemp=	10.7	if	year==	2009	&	mon4	==1	&	st15==1
replace unemp=	10.8	if	year==	2009	&	mon5	==1	&	st15==1
replace unemp=	10.9	if	year==	2009	&	mon6	==1	&	st15==1
replace unemp=	10.8	if	year==	2009	&	mon7	==1	&	st15==1
replace unemp=	10.7	if	year==	2009	&	mon8	==1	&	st15==1
replace unemp=	10.6	if	year==	2009	&	mon9	==1	&	st15==1
replace unemp=	10.5	if	year==	2009	&	mon10	==1	&	st15==1
replace unemp=	10.6	if	year==	2009	&	mon11	==1	&	st15==1
replace unemp=	10.7	if	year==	2009	&	mon12	==1	&	st15==1


replace unemp=	10.7	if	year==	2010	&	mon1	==1	&	st15==1
replace unemp=	10.7	if	year==	2010	&	mon2	==1	&	st15==1
replace unemp=	10.6	if	year==	2010	&	mon3	==1	&	st15==1
replace unemp=	10.5	if	year==	2010	&	mon4	==1	&	st15==1
replace unemp=	10.4	if	year==	2010	&	mon5	==1	&	st15==1
replace unemp=	10.3	if	year==	2010	&	mon6	==1	&	st15==1
replace unemp=	10.1	if	year==	2010	&	mon7	==1	&	st15==1
replace unemp=	10		if	year==	2010	&	mon8	==1	&	st15==1
replace unemp=	9.9		if	year==	2010	&	mon9	==1	&	st15==1
replace unemp=	9.7		if	year==	2010	&	mon10	==1	&	st15==1
replace unemp=	9.6		if	year==	2010	&	mon11	==1	&	st15==1
replace unemp=	9.5 	if	year==	2010	&	mon12	==1	&	st15==1

replace unemp=	3.6	if	year==	2007	&	mon1	==1	&	st16==1
replace unemp=	3.6	if	year==	2007	&	mon2	==1	&	st16==1
replace unemp=	3.6	if	year==	2007	&	mon3	==1	&	st16==1
replace unemp=	3.7	if	year==	2007	&	mon4	==1	&	st16==1
replace unemp=	3.7	if	year==	2007	&	mon5	==1	&	st16==1
replace unemp=	3.8	if	year==	2007	&	mon6	==1	&	st16==1
replace unemp=	3.8	if	year==	2007	&	mon7	==1	&	st16==1
replace unemp=	3.8	if	year==	2007	&	mon8	==1	&	st16==1
replace unemp=	3.9	if	year==	2007	&	mon9	==1	&	st16==1
replace unemp=	3.9	if	year==	2007	&	mon10	==1	&	st16==1
replace unemp=	3.8	if	year==	2007	&	mon11	==1	&	st16==1
replace unemp=	3.9	if	year==	2007	&	mon12	==1	&	st16==1
replace unemp=	3.9	if	year==	2008	&	mon1	==1	&	st16==1
replace unemp=	3.8	if	year==	2008	&	mon2	==1	&	st16==1
replace unemp=	3.9	if	year==	2008	&	mon3	==1	&	st16==1
replace unemp=	3.9	if	year==	2008	&	mon4	==1	&	st16==1
replace unemp=	4.2	if	year==	2008	&	mon5	==1	&	st16==1
replace unemp=	4.3	if	year==	2008	&	mon6	==1	&	st16==1
replace unemp=	4.5	if	year==	2008	&	mon7	==1	&	st16==1
replace unemp=	4.6	if	year==	2008	&	mon8	==1	&	st16==1
replace unemp=	4.6	if	year==	2008	&	mon9	==1	&	st16==1
replace unemp=	4.7	if	year==	2008	&	mon10	==1	&	st16==1
replace unemp=	4.8	if	year==	2008	&	mon11	==1	&	st16==1
replace unemp=	4.9	if	year==	2008	&	mon12	==1	&	st16==1
replace unemp=	5.1	if	year==	2009	&	mon1	==1	&	st16==1
replace unemp=	5.2	if	year==	2009	&	mon2	==1	&	st16==1
replace unemp=	5.3	if	year==	2009	&	mon3	==1	&	st16==1
replace unemp=	5.3	if	year==	2009	&	mon4	==1	&	st16==1
replace unemp=	5.5	if	year==	2009	&	mon5	==1	&	st16==1
replace unemp=	5.6	if	year==	2009	&	mon6	==1	&	st16==1
replace unemp=	5.8	if	year==	2009	&	mon7	==1	&	st16==1
replace unemp=	5.9	if	year==	2009	&	mon8	==1	&	st16==1
replace unemp=	5.9	if	year==	2009	&	mon9	==1	&	st16==1
replace unemp=	6	if	year==	2009	&	mon10	==1	&	st16==1
replace unemp=	6	if	year==	2009	&	mon11	==1	&	st16==1
replace unemp=	6	if	year==	2009	&	mon12	==1	&	st16==1

replace unemp=	6.1	if	year==	2010	&	mon1	==1	&	st16==1
replace unemp=	6.1	if	year==	2010	&	mon2	==1	&	st16==1
replace unemp=	6.1	if	year==	2010	&	mon3	==1	&	st16==1
replace unemp=	6.1	if	year==	2010	&	mon4	==1	&	st16==1
replace unemp=	6.1	if	year==	2010	&	mon5	==1	&	st16==1
replace unemp=	6.1	if	year==	2010	&	mon6	==1	&	st16==1
replace unemp=	6.2	if	year==	2010	&	mon7	==1	&	st16==1
replace unemp=	6.2	if	year==	2010	&	mon8	==1	&	st16==1
replace unemp=	6.2	if	year==	2010	&	mon9	==1	&	st16==1
replace unemp=	6.2	if	year==	2010	&	mon10	==1	&	st16==1
replace unemp=	6.2	if	year==	2010	&	mon11	==1	&	st16==1
replace unemp=	6.1	if	year==	2010	&	mon12	==1	&	st16==1


replace unemp=	4.1	if	year==	2007	&	mon1	==1	&	st17==1
replace unemp=	4.1	if	year==	2007	&	mon2	==1	&	st17==1
replace unemp=	4.1	if	year==	2007	&	mon3	==1	&	st17==1
replace unemp=	4.1	if	year==	2007	&	mon4	==1	&	st17==1
replace unemp=	4.1	if	year==	2007	&	mon5	==1	&	st17==1
replace unemp=	4.2	if	year==	2007	&	mon6	==1	&	st17==1
replace unemp=	4.2	if	year==	2007	&	mon7	==1	&	st17==1
replace unemp=	4.2	if	year==	2007	&	mon8	==1	&	st17==1
replace unemp=	4.2	if	year==	2007	&	mon9	==1	&	st17==1
replace unemp=	4.1	if	year==	2007	&	mon10	==1	&	st17==1
replace unemp=	4.1	if	year==	2007	&	mon11	==1	&	st17==1
replace unemp=	4	if	year==	2007	&	mon12	==1	&	st17==1
replace unemp=	4	if	year==	2008	&	mon1	==1	&	st17==1
replace unemp=	4	if	year==	2008	&	mon2	==1	&	st17==1
replace unemp=	4	if	year==	2008	&	mon3	==1	&	st17==1
replace unemp=	4.1	if	year==	2008	&	mon4	==1	&	st17==1
replace unemp=	4.3	if	year==	2008	&	mon5	==1	&	st17==1
replace unemp=	4.4	if	year==	2008	&	mon6	==1	&	st17==1
replace unemp=	4.6	if	year==	2008	&	mon7	==1	&	st17==1
replace unemp=	4.7	if	year==	2008	&	mon8	==1	&	st17==1
replace unemp=	4.8	if	year==	2008	&	mon9	==1	&	st17==1
replace unemp=	5	if	year==	2008	&	mon10	==1	&	st17==1
replace unemp=	5.2	if	year==	2008	&	mon11	==1	&	st17==1
replace unemp=	5.5	if	year==	2008	&	mon12	==1	&	st17==1
replace unemp=	5.8	if	year==	2009	&	mon1	==1	&	st17==1
replace unemp=	6.2	if	year==	2009	&	mon2	==1	&	st17==1
replace unemp=	6.6	if	year==	2009	&	mon3	==1	&	st17==1
replace unemp=	6.9	if	year==	2009	&	mon4	==1	&	st17==1
replace unemp=	7.3	if	year==	2009	&	mon5	==1	&	st17==1
replace unemp=	7.5	if	year==	2009	&	mon6	==1	&	st17==1
replace unemp=	7.6	if	year==	2009	&	mon7	==1	&	st17==1
replace unemp=	7.6	if	year==	2009	&	mon8	==1	&	st17==1
replace unemp=	7.5	if	year==	2009	&	mon9	==1	&	st17==1
replace unemp=	7.4	if	year==	2009	&	mon10	==1	&	st17==1
replace unemp=	7.3	if	year==	2009	&	mon11	==1	&	st17==1
replace unemp=	7.3	if	year==	2009	&	mon12	==1	&	st17==1


replace unemp=	7.2	if	year==	2010	&	mon1	==1	&	st17==1
replace unemp=	7.2	if	year==	2010	&	mon2	==1	&	st17==1
replace unemp=	7.2	if	year==	2010	&	mon3	==1	&	st17==1
replace unemp=	7.1	if	year==	2010	&	mon4	==1	&	st17==1
replace unemp=	7.1	if	year==	2010	&	mon5	==1	&	st17==1
replace unemp=	7	if	year==	2010	&	mon6	==1	&	st17==1
replace unemp=	7	if	year==	2010	&	mon7	==1	&	st17==1
replace unemp=	7	if	year==	2010	&	mon8	==1	&	st17==1
replace unemp=	7	if	year==	2010	&	mon9	==1	&	st17==1
replace unemp=	6.9	if	year==	2010	&	mon10	==1	&	st17==1
replace unemp=	6.9	if	year==	2010	&	mon11	==1	&	st17==1
replace unemp=	6.8	if	year==	2010	&	mon12	==1	&	st17==1

replace unemp=	5.7	if	year==	2007	&	mon1	==1	&	st18==1
replace unemp=	5.7	if	year==	2007	&	mon2	==1	&	st18==1
replace unemp=	5.6	if	year==	2007	&	mon3	==1	&	st18==1
replace unemp=	5.5	if	year==	2007	&	mon4	==1	&	st18==1
replace unemp=	5.5	if	year==	2007	&	mon5	==1	&	st18==1
replace unemp=	5.5	if	year==	2007	&	mon6	==1	&	st18==1
replace unemp=	5.5	if	year==	2007	&	mon7	==1	&	st18==1
replace unemp=	5.5	if	year==	2007	&	mon8	==1	&	st18==1
replace unemp=	5.5	if	year==	2007	&	mon9	==1	&	st18==1
replace unemp=	5.6	if	year==	2007	&	mon10	==1	&	st18==1
replace unemp=	5.6	if	year==	2007	&	mon11	==1	&	st18==1
replace unemp=	5.6	if	year==	2007	&	mon12	==1	&	st18==1
replace unemp=	5.6	if	year==	2008	&	mon1	==1	&	st18==1
replace unemp=	5.6	if	year==	2008	&	mon2	==1	&	st18==1
replace unemp=	5.7	if	year==	2008	&	mon3	==1	&	st18==1
replace unemp=	5.9	if	year==	2008	&	mon4	==1	&	st18==1
replace unemp=	6.1	if	year==	2008	&	mon5	==1	&	st18==1
replace unemp=	6.4	if	year==	2008	&	mon6	==1	&	st18==1
replace unemp=	6.6	if	year==	2008	&	mon7	==1	&	st18==1
replace unemp=	6.8	if	year==	2008	&	mon8	==1	&	st18==1
replace unemp=	7	if	year==	2008	&	mon9	==1	&	st18==1
replace unemp=	7.4	if	year==	2008	&	mon10	==1	&	st18==1
replace unemp=	7.9	if	year==	2008	&	mon11	==1	&	st18==1
replace unemp=	8.5	if	year==	2008	&	mon12	==1	&	st18==1
replace unemp=	9.2	if	year==	2009	&	mon1	==1	&	st18==1
replace unemp=	9.8	if	year==	2009	&	mon2	==1	&	st18==1
replace unemp=	10.3	if	year==	2009	&	mon3	==1	&	st18==1
replace unemp=	10.7	if	year==	2009	&	mon4	==1	&	st18==1
replace unemp=	10.9	if	year==	2009	&	mon5	==1	&	st18==1
replace unemp=	11	if	year==	2009	&	mon6	==1	&	st18==1
replace unemp=	11.1	if	year==	2009	&	mon7	==1	&	st18==1
replace unemp=	11.1	if	year==	2009	&	mon8	==1	&	st18==1
replace unemp=	11	if	year==	2009	&	mon9	==1	&	st18==1
replace unemp=	11	if	year==	2009	&	mon10	==1	&	st18==1
replace unemp=	10.9	if	year==	2009	&	mon11	==1	&	st18==1
replace unemp=	11	if	year==	2009	&	mon12	==1	&	st18==1

replace unemp=	11		if	year==	2010	&	mon1	==1	&	st18==1
replace unemp=	10.9	if	year==	2010	&	mon2	==1	&	st18==1
replace unemp=	10.8	if	year==	2010	&	mon3	==1	&	st18==1
replace unemp=	10.6	if	year==	2010	&	mon4	==1	&	st18==1
replace unemp=	10.4	if	year==	2010	&	mon5	==1	&	st18==1
replace unemp=	10.3	if	year==	2010	&	mon6	==1	&	st18==1
replace unemp=	10.2	if	year==	2010	&	mon7	==1	&	st18==1
replace unemp=	10.2	if	year==	2010	&	mon8	==1	&	st18==1
replace unemp=	10.2	if	year==	2010	&	mon9	==1	&	st18==1
replace unemp=	10.2	if	year==	2010	&	mon10	==1	&	st18==1
replace unemp=	10.2	if	year==	2010	&	mon11	==1	&	st18==1
replace unemp=	10.3	if	year==	2010	&	mon12	==1	&	st18==1



replace unemp=	3.9	if	year==	2007	&	mon1	==1	&	st19==1
replace unemp=	3.9	if	year==	2007	&	mon2	==1	&	st19==1
replace unemp=	3.8	if	year==	2007	&	mon3	==1	&	st19==1
replace unemp=	3.8	if	year==	2007	&	mon4	==1	&	st19==1
replace unemp=	3.8	if	year==	2007	&	mon5	==1	&	st19==1
replace unemp=	3.8	if	year==	2007	&	mon6	==1	&	st19==1
replace unemp=	3.7	if	year==	2007	&	mon7	==1	&	st19==1
replace unemp=	3.7	if	year==	2007	&	mon8	==1	&	st19==1
replace unemp=	3.6	if	year==	2007	&	mon9	==1	&	st19==1
replace unemp=	3.7	if	year==	2007	&	mon10	==1	&	st19==1
replace unemp=	3.7	if	year==	2007	&	mon11	==1	&	st19==1
replace unemp=	3.7	if	year==	2007	&	mon12	==1	&	st19==1
replace unemp=	3.8	if	year==	2008	&	mon1	==1	&	st19==1
replace unemp=	3.8	if	year==	2008	&	mon2	==1	&	st19==1
replace unemp=	3.8	if	year==	2008	&	mon3	==1	&	st19==1
replace unemp=	3.8	if	year==	2008	&	mon4	==1	&	st19==1
replace unemp=	3.9	if	year==	2008	&	mon5	==1	&	st19==1
replace unemp=	4.1	if	year==	2008	&	mon6	==1	&	st19==1
replace unemp=	4.4	if	year==	2008	&	mon7	==1	&	st19==1
replace unemp=	4.6	if	year==	2008	&	mon8	==1	&	st19==1
replace unemp=	4.9	if	year==	2008	&	mon9	==1	&	st19==1
replace unemp=	5.1	if	year==	2008	&	mon10	==1	&	st19==1
replace unemp=	5.3	if	year==	2008	&	mon11	==1	&	st19==1
replace unemp=	5.4	if	year==	2008	&	mon12	==1	&	st19==1
replace unemp=	5.6	if	year==	2009	&	mon1	==1	&	st19==1
replace unemp=	5.8	if	year==	2009	&	mon2	==1	&	st19==1
replace unemp=	6.1	if	year==	2009	&	mon3	==1	&	st19==1
replace unemp=	6.3	if	year==	2009	&	mon4	==1	&	st19==1
replace unemp=	6.6	if	year==	2009	&	mon5	==1	&	st19==1
replace unemp=	6.8	if	year==	2009	&	mon6	==1	&	st19==1
replace unemp=	6.9	if	year==	2009	&	mon7	==1	&	st19==1
replace unemp=	7	if	year==	2009	&	mon8	==1	&	st19==1
replace unemp=	7	if	year==	2009	&	mon9	==1	&	st19==1
replace unemp=	7.1	if	year==	2009	&	mon10	==1	&	st19==1
replace unemp=	7.1	if	year==	2009	&	mon11	==1	&	st19==1
replace unemp=	7.1	if	year==	2009	&	mon12	==1	&	st19==1

replace unemp=	7.1	if	year==	2010	&	mon1	==1	&	st19==1
replace unemp=	7.1	if	year==	2010	&	mon2	==1	&	st19==1
replace unemp=	7.2	if	year==	2010	&	mon3	==1	&	st19==1
replace unemp=	7.2	if	year==	2010	&	mon4	==1	&	st19==1
replace unemp=	7.3	if	year==	2010	&	mon5	==1	&	st19==1
replace unemp=	7.5	if	year==	2010	&	mon6	==1	&	st19==1
replace unemp=	7.6	if	year==	2010	&	mon7	==1	&	st19==1
replace unemp=	7.7	if	year==	2010	&	mon8	==1	&	st19==1
replace unemp=	7.7	if	year==	2010	&	mon9	==1	&	st19==1
replace unemp=	7.7	if	year==	2010	&	mon10	==1	&	st19==1
replace unemp=	7.7	if	year==	2010	&	mon11	==1	&	st19==1
replace unemp=	7.7	if	year==	2010	&	mon12	==1	&	st19==1


replace unemp=	4.6	if	year==	2007	&	mon1	==1	&	st20==1
replace unemp=	4.5	if	year==	2007	&	mon2	==1	&	st20==1
replace unemp=	4.5	if	year==	2007	&	mon3	==1	&	st20==1
replace unemp=	4.5	if	year==	2007	&	mon4	==1	&	st20==1
replace unemp=	4.6	if	year==	2007	&	mon5	==1	&	st20==1
replace unemp=	4.7	if	year==	2007	&	mon6	==1	&	st20==1
replace unemp=	4.8	if	year==	2007	&	mon7	==1	&	st20==1
replace unemp=	4.8	if	year==	2007	&	mon8	==1	&	st20==1
replace unemp=	4.9	if	year==	2007	&	mon9	==1	&	st20==1
replace unemp=	4.9	if	year==	2007	&	mon10	==1	&	st20==1
replace unemp=	4.8	if	year==	2007	&	mon11	==1	&	st20==1
replace unemp=	4.8	if	year==	2007	&	mon12	==1	&	st20==1
replace unemp=	4.7	if	year==	2008	&	mon1	==1	&	st20==1
replace unemp=	4.7	if	year==	2008	&	mon2	==1	&	st20==1
replace unemp=	4.7	if	year==	2008	&	mon3	==1	&	st20==1
replace unemp=	4.8	if	year==	2008	&	mon4	==1	&	st20==1
replace unemp=	5	if	year==	2008	&	mon5	==1	&	st20==1
replace unemp=	5.2	if	year==	2008	&	mon6	==1	&	st20==1
replace unemp=	5.3	if	year==	2008	&	mon7	==1	&	st20==1
replace unemp=	5.5	if	year==	2008	&	mon8	==1	&	st20==1
replace unemp=	5.7	if	year==	2008	&	mon9	==1	&	st20==1
replace unemp=	6	if	year==	2008	&	mon10	==1	&	st20==1
replace unemp=	6.4	if	year==	2008	&	mon11	==1	&	st20==1
replace unemp=	6.9	if	year==	2008	&	mon12	==1	&	st20==1
replace unemp=	7.4	if	year==	2009	&	mon1	==1	&	st20==1
replace unemp=	7.8	if	year==	2009	&	mon2	==1	&	st20==1
replace unemp=	8.1	if	year==	2009	&	mon3	==1	&	st20==1
replace unemp=	8.3	if	year==	2009	&	mon4	==1	&	st20==1
replace unemp=	8.3	if	year==	2009	&	mon5	==1	&	st20==1
replace unemp=	8.4	if	year==	2009	&	mon6	==1	&	st20==1
replace unemp=	8.4	if	year==	2009	&	mon7	==1	&	st20==1
replace unemp=	8.3	if	year==	2009	&	mon8	==1	&	st20==1
replace unemp=	8.3	if	year==	2009	&	mon9	==1	&	st20==1
replace unemp=	8.3	if	year==	2009	&	mon10	==1	&	st20==1
replace unemp=	8.3	if	year==	2009	&	mon11	==1	&	st20==1
replace unemp=	8.4	if	year==	2009	&	mon12	==1	&	st20==1

replace unemp=	8.4	if	year==	2010	&	mon1	==1	&	st20==1
replace unemp=	8.4	if	year==	2010	&	mon2	==1	&	st20==1
replace unemp=	8.3	if	year==	2010	&	mon3	==1	&	st20==1
replace unemp=	8.2	if	year==	2010	&	mon4	==1	&	st20==1
replace unemp=	8	if	year==	2010	&	mon5	==1	&	st20==1
replace unemp=	7.9	if	year==	2010	&	mon6	==1	&	st20==1
replace unemp=	7.8	if	year==	2010	&	mon7	==1	&	st20==1
replace unemp=	7.7	if	year==	2010	&	mon8	==1	&	st20==1
replace unemp=	7.6	if	year==	2010	&	mon9	==1	&	st20==1
replace unemp=	7.6	if	year==	2010	&	mon10	==1	&	st20==1
replace unemp=	7.5	if	year==	2010	&	mon11	==1	&	st20==1
replace unemp=	7.5	if	year==	2010	&	mon12	==1	&	st20==1


replace unemp=	3.6	if	year==	2007	&	mon1	==1	&	st21==1
replace unemp=	3.5	if	year==	2007	&	mon2	==1	&	st21==1
replace unemp=	3.5	if	year==	2007	&	mon3	==1	&	st21==1
replace unemp=	3.5	if	year==	2007	&	mon4	==1	&	st21==1
replace unemp=	3.5	if	year==	2007	&	mon5	==1	&	st21==1
replace unemp=	3.6	if	year==	2007	&	mon6	==1	&	st21==1
replace unemp=	3.6	if	year==	2007	&	mon7	==1	&	st21==1
replace unemp=	3.6	if	year==	2007	&	mon8	==1	&	st21==1
replace unemp=	3.6	if	year==	2007	&	mon9	==1	&	st21==1
replace unemp=	3.6	if	year==	2007	&	mon10	==1	&	st21==1
replace unemp=	3.6	if	year==	2007	&	mon11	==1	&	st21==1
replace unemp=	3.6	if	year==	2007	&	mon12	==1	&	st21==1
replace unemp=	3.6	if	year==	2008	&	mon1	==1	&	st21==1
replace unemp=	3.6	if	year==	2008	&	mon2	==1	&	st21==1
replace unemp=	3.7	if	year==	2008	&	mon3	==1	&	st21==1
replace unemp=	3.8	if	year==	2008	&	mon4	==1	&	st21==1
replace unemp=	4	if	year==	2008	&	mon5	==1	&	st21==1
replace unemp=	4.3	if	year==	2008	&	mon6	==1	&	st21==1
replace unemp=	4.5	if	year==	2008	&	mon7	==1	&	st21==1
replace unemp=	4.7	if	year==	2008	&	mon8	==1	&	st21==1
replace unemp=	4.9	if	year==	2008	&	mon9	==1	&	st21==1
replace unemp=	5.2	if	year==	2008	&	mon10	==1	&	st21==1
replace unemp=	5.5	if	year==	2008	&	mon11	==1	&	st21==1
replace unemp=	5.8	if	year==	2008	&	mon12	==1	&	st21==1
replace unemp=	6.2	if	year==	2009	&	mon1	==1	&	st21==1
replace unemp=	6.5	if	year==	2009	&	mon2	==1	&	st21==1
replace unemp=	6.8	if	year==	2009	&	mon3	==1	&	st21==1
replace unemp=	7	if	year==	2009	&	mon4	==1	&	st21==1
replace unemp=	7.1	if	year==	2009	&	mon5	==1	&	st21==1
replace unemp=	7.3	if	year==	2009	&	mon6	==1	&	st21==1
replace unemp=	7.3	if	year==	2009	&	mon7	==1	&	st21==1
replace unemp=	7.4	if	year==	2009	&	mon8	==1	&	st21==1
replace unemp=	7.4	if	year==	2009	&	mon9	==1	&	st21==1
replace unemp=	7.5	if	year==	2009	&	mon10	==1	&	st21==1
replace unemp=	7.6	if	year==	2009	&	mon11	==1	&	st21==1
replace unemp=	7.6	if	year==	2009	&	mon12	==1	&	st21==1

replace unemp=	7.7	if	year==	2010	&	mon1	==1	&	st21==1
replace unemp=	7.6	if	year==	2010	&	mon2	==1	&	st21==1
replace unemp=	7.6	if	year==	2010	&	mon3	==1	&	st21==1
replace unemp=	7.5	if	year==	2010	&	mon4	==1	&	st21==1
replace unemp=	7.4	if	year==	2010	&	mon5	==1	&	st21==1
replace unemp=	7.4	if	year==	2010	&	mon6	==1	&	st21==1
replace unemp=	7.4	if	year==	2010	&	mon7	==1	&	st21==1
replace unemp=	7.4	if	year==	2010	&	mon8	==1	&	st21==1
replace unemp=	7.4	if	year==	2010	&	mon9	==1	&	st21==1
replace unemp=	7.4	if	year==	2010	&	mon10	==1	&	st21==1
replace unemp=	7.4	if	year==	2010	&	mon11	==1	&	st21==1
replace unemp=	7.4	if	year==	2010	&	mon12	==1	&	st21==1


replace unemp=	4.6	if	year==	2007	&	mon1	==1	&	st22==1
replace unemp=	4.5	if	year==	2007	&	mon2	==1	&	st22==1
replace unemp=	4.5	if	year==	2007	&	mon3	==1	&	st22==1
replace unemp=	4.5	if	year==	2007	&	mon4	==1	&	st22==1
replace unemp=	4.4	if	year==	2007	&	mon5	==1	&	st22==1
replace unemp=	4.4	if	year==	2007	&	mon6	==1	&	st22==1
replace unemp=	4.4	if	year==	2007	&	mon7	==1	&	st22==1
replace unemp=	4.4	if	year==	2007	&	mon8	==1	&	st22==1
replace unemp=	4.4	if	year==	2007	&	mon9	==1	&	st22==1
replace unemp=	4.4	if	year==	2007	&	mon10	==1	&	st22==1
replace unemp=	4.4	if	year==	2007	&	mon11	==1	&	st22==1
replace unemp=	4.4	if	year==	2007	&	mon12	==1	&	st22==1
replace unemp=	4.4	if	year==	2008	&	mon1	==1	&	st22==1
replace unemp=	4.5	if	year==	2008	&	mon2	==1	&	st22==1
replace unemp=	4.6	if	year==	2008	&	mon3	==1	&	st22==1
replace unemp=	4.7	if	year==	2008	&	mon4	==1	&	st22==1
replace unemp=	4.9	if	year==	2008	&	mon5	==1	&	st22==1
replace unemp=	5.1	if	year==	2008	&	mon6	==1	&	st22==1
replace unemp=	5.3	if	year==	2008	&	mon7	==1	&	st22==1
replace unemp=	5.5	if	year==	2008	&	mon8	==1	&	st22==1
replace unemp=	5.7	if	year==	2008	&	mon9	==1	&	st22==1
replace unemp=	6	if	year==	2008	&	mon10	==1	&	st22==1
replace unemp=	6.3	if	year==	2008	&	mon11	==1	&	st22==1
replace unemp=	6.7	if	year==	2008	&	mon12	==1	&	st22==1
replace unemp=	7.1	if	year==	2009	&	mon1	==1	&	st22==1
replace unemp=	7.4	if	year==	2009	&	mon2	==1	&	st22==1
replace unemp=	7.7	if	year==	2009	&	mon3	==1	&	st22==1
replace unemp=	7.9	if	year==	2009	&	mon4	==1	&	st22==1
replace unemp=	8.1	if	year==	2009	&	mon5	==1	&	st22==1
replace unemp=	8.3	if	year==	2009	&	mon6	==1	&	st22==1
replace unemp=	8.5	if	year==	2009	&	mon7	==1	&	st22==1
replace unemp=	8.6	if	year==	2009	&	mon8	==1	&	st22==1
replace unemp=	8.7	if	year==	2009	&	mon9	==1	&	st22==1
replace unemp=	8.8	if	year==	2009	&	mon10	==1	&	st22==1
replace unemp=	8.8	if	year==	2009	&	mon11	==1	&	st22==1
replace unemp=	8.8	if	year==	2009	&	mon12	==1	&	st22==1

replace unemp=	8.8	if	year==	2010	&	mon1	==1	&	st22==1
replace unemp=	8.8	if	year==	2010	&	mon2	==1	&	st22==1
replace unemp=	8.7	if	year==	2010	&	mon3	==1	&	st22==1
replace unemp=	8.6	if	year==	2010	&	mon4	==1	&	st22==1
replace unemp=	8.5	if	year==	2010	&	mon5	==1	&	st22==1
replace unemp=	8.4	if	year==	2010	&	mon6	==1	&	st22==1
replace unemp=	8.4	if	year==	2010	&	mon7	==1	&	st22==1
replace unemp=	8.4	if	year==	2010	&	mon8	==1	&	st22==1
replace unemp=	8.3	if	year==	2010	&	mon9	==1	&	st22==1
replace unemp=	8.3	if	year==	2010	&	mon10	==1	&	st22==1
replace unemp=	8.3	if	year==	2010	&	mon11	==1	&	st22==1
replace unemp=	8.3	if	year==	2010	&	mon12	==1	&	st22==1


replace unemp=	6.6	if	year==	2007	&	mon1	==1	&	st23==1
replace unemp=	6.5	if	year==	2007	&	mon2	==1	&	st23==1
replace unemp=	6.5	if	year==	2007	&	mon3	==1	&	st23==1
replace unemp=	6.5	if	year==	2007	&	mon4	==1	&	st23==1
replace unemp=	6.5	if	year==	2007	&	mon5	==1	&	st23==1
replace unemp=	6.6	if	year==	2007	&	mon6	==1	&	st23==1
replace unemp=	6.7	if	year==	2007	&	mon7	==1	&	st23==1
replace unemp=	6.8	if	year==	2007	&	mon8	==1	&	st23==1
replace unemp=	6.9	if	year==	2007	&	mon9	==1	&	st23==1
replace unemp=	6.9	if	year==	2007	&	mon10	==1	&	st23==1
replace unemp=	6.9	if	year==	2007	&	mon11	==1	&	st23==1
replace unemp=	6.9	if	year==	2007	&	mon12	==1	&	st23==1
replace unemp=	6.8	if	year==	2008	&	mon1	==1	&	st23==1
replace unemp=	6.8	if	year==	2008	&	mon2	==1	&	st23==1
replace unemp=	6.8	if	year==	2008	&	mon3	==1	&	st23==1
replace unemp=	7	if	year==	2008	&	mon4	==1	&	st23==1
replace unemp=	7.3	if	year==	2008	&	mon5	==1	&	st23==1
replace unemp=	7.6	if	year==	2008	&	mon6	==1	&	st23==1
replace unemp=	8	if	year==	2008	&	mon7	==1	&	st23==1
replace unemp=	8.4	if	year==	2008	&	mon8	==1	&	st23==1
replace unemp=	8.7	if	year==	2008	&	mon9	==1	&	st23==1
replace unemp=	9.1	if	year==	2008	&	mon10	==1	&	st23==1
replace unemp=	9.5	if	year==	2008	&	mon11	==1	&	st23==1
replace unemp=	10	if	year==	2008	&	mon12	==1	&	st23==1
replace unemp=	10.5	if	year==	2009	&	mon1	==1	&	st23==1
replace unemp=	10.9	if	year==	2009	&	mon2	==1	&	st23==1
replace unemp=	11.4	if	year==	2009	&	mon3	==1	&	st23==1
replace unemp=	11.7	if	year==	2009	&	mon4	==1	&	st23==1
replace unemp=	12		if	year==	2009	&	mon5	==1	&	st23==1
replace unemp=	12.2	if	year==	2009	&	mon6	==1	&	st23==1
replace unemp=	12.4	if	year==	2009	&	mon7	==1	&	st23==1
replace unemp=	12.7	if	year==	2009	&	mon8	==1	&	st23==1
replace unemp=	12.9	if	year==	2009	&	mon9	==1	&	st23==1
replace unemp=	13		if	year==	2009	&	mon10	==1	&	st23==1
replace unemp=	13		if	year==	2009	&	mon11	==1	&	st23==1
replace unemp=	12.9	if	year==	2009	&	mon12	==1	&	st23==1

replace unemp=	12.7	if	year==	2010	&	mon1	==1	&	st23==1
replace unemp=	12.4	if	year==	2010	&	mon2	==1	&	st23==1
replace unemp=	12.1	if	year==	2010	&	mon3	==1	&	st23==1
replace unemp=	11.9	if	year==	2010	&	mon4	==1	&	st23==1
replace unemp=	11.7	if	year==	2010	&	mon5	==1	&	st23==1
replace unemp=	11.6	if	year==	2010	&	mon6	==1	&	st23==1
replace unemp=	11.5	if	year==	2010	&	mon7	==1	&	st23==1
replace unemp=	11.4	if	year==	2010	&	mon8	==1	&	st23==1
replace unemp=	11.3	if	year==	2010	&	mon9	==1	&	st23==1
replace unemp=	11.2	if	year==	2010	&	mon10	==1	&	st23==1
replace unemp=	11.1	if	year==	2010	&	mon11	==1	&	st23==1
replace unemp=	11		if	year==	2010	&	mon12	==1	&	st23==1


replace unemp=	4.5	if	year==	2007	&	mon1	==1	&	st24==1
replace unemp=	4.5	if	year==	2007	&	mon2	==1	&	st24==1
replace unemp=	4.5	if	year==	2007	&	mon3	==1	&	st24==1
replace unemp=	4.6	if	year==	2007	&	mon4	==1	&	st24==1
replace unemp=	4.6	if	year==	2007	&	mon5	==1	&	st24==1
replace unemp=	4.6	if	year==	2007	&	mon6	==1	&	st24==1
replace unemp=	4.7	if	year==	2007	&	mon7	==1	&	st24==1
replace unemp=	4.7	if	year==	2007	&	mon8	==1	&	st24==1
replace unemp=	4.7	if	year==	2007	&	mon9	==1	&	st24==1
replace unemp=	4.7	if	year==	2007	&	mon10	==1	&	st24==1
replace unemp=	4.7	if	year==	2007	&	mon11	==1	&	st24==1
replace unemp=	4.7	if	year==	2007	&	mon12	==1	&	st24==1
replace unemp=	4.7	if	year==	2008	&	mon1	==1	&	st24==1
replace unemp=	4.7	if	year==	2008	&	mon2	==1	&	st24==1
replace unemp=	4.8	if	year==	2008	&	mon3	==1	&	st24==1
replace unemp=	5	if	year==	2008	&	mon4	==1	&	st24==1
replace unemp=	5.1	if	year==	2008	&	mon5	==1	&	st24==1
replace unemp=	5.3	if	year==	2008	&	mon6	==1	&	st24==1
replace unemp=	5.4	if	year==	2008	&	mon7	==1	&	st24==1
replace unemp=	5.5	if	year==	2008	&	mon8	==1	&	st24==1
replace unemp=	5.6	if	year==	2008	&	mon9	==1	&	st24==1
replace unemp=	5.9	if	year==	2008	&	mon10	==1	&	st24==1
replace unemp=	6.3	if	year==	2008	&	mon11	==1	&	st24==1
replace unemp=	6.7	if	year==	2008	&	mon12	==1	&	st24==1
replace unemp=	7.3	if	year==	2009	&	mon1	==1	&	st24==1
replace unemp=	7.7	if	year==	2009	&	mon2	==1	&	st24==1
replace unemp=	8.1	if	year==	2009	&	mon3	==1	&	st24==1
replace unemp=	8.4	if	year==	2009	&	mon4	==1	&	st24==1
replace unemp=	8.5	if	year==	2009	&	mon5	==1	&	st24==1
replace unemp=	8.5	if	year==	2009	&	mon6	==1	&	st24==1
replace unemp=	8.4	if	year==	2009	&	mon7	==1	&	st24==1
replace unemp=	8.3	if	year==	2009	&	mon8	==1	&	st24==1
replace unemp=	8.1	if	year==	2009	&	mon9	==1	&	st24==1
replace unemp=	8	if	year==	2009	&	mon10	==1	&	st24==1
replace unemp=	7.9	if	year==	2009	&	mon11	==1	&	st24==1
replace unemp=	7.8	if	year==	2009	&	mon12	==1	&	st24==1

replace unemp=	7.8	if	year==	2010	&	mon1	==1	&	st24==1
replace unemp=	7.7	if	year==	2010	&	mon2	==1	&	st24==1
replace unemp=	7.6	if	year==	2010	&	mon3	==1	&	st24==1
replace unemp=	7.5	if	year==	2010	&	mon4	==1	&	st24==1
replace unemp=	7.4	if	year==	2010	&	mon5	==1	&	st24==1
replace unemp=	7.3	if	year==	2010	&	mon6	==1	&	st24==1
replace unemp=	7.2	if	year==	2010	&	mon7	==1	&	st24==1
replace unemp=	7.1	if	year==	2010	&	mon8	==1	&	st24==1
replace unemp=	7.1	if	year==	2010	&	mon9	==1	&	st24==1
replace unemp=	7	if	year==	2010	&	mon10	==1	&	st24==1
replace unemp=	7	if	year==	2010	&	mon11	==1	&	st24==1
replace unemp=	6.9	if	year==	2010	&	mon12	==1	&	st24==1


replace unemp=	6.5	if	year==	2007	&	mon1	==1	&	st25==1
replace unemp=	6.5	if	year==	2007	&	mon2	==1	&	st25==1
replace unemp=	6.4	if	year==	2007	&	mon3	==1	&	st25==1
replace unemp=	6.2	if	year==	2007	&	mon4	==1	&	st25==1
replace unemp=	6.2	if	year==	2007	&	mon5	==1	&	st25==1
replace unemp=	6.1	if	year==	2007	&	mon6	==1	&	st25==1
replace unemp=	6.1	if	year==	2007	&	mon7	==1	&	st25==1
replace unemp=	6.1	if	year==	2007	&	mon8	==1	&	st25==1
replace unemp=	6.2	if	year==	2007	&	mon9	==1	&	st25==1
replace unemp=	6.2	if	year==	2007	&	mon10	==1	&	st25==1
replace unemp=	6.1	if	year==	2007	&	mon11	==1	&	st25==1
replace unemp=	6.1	if	year==	2007	&	mon12	==1	&	st25==1
replace unemp=	6	if	year==	2008	&	mon1	==1	&	st25==1
replace unemp=	6	if	year==	2008	&	mon2	==1	&	st25==1
replace unemp=	6.1	if	year==	2008	&	mon3	==1	&	st25==1
replace unemp=	6.3	if	year==	2008	&	mon4	==1	&	st25==1
replace unemp=	6.6	if	year==	2008	&	mon5	==1	&	st25==1
replace unemp=	6.8	if	year==	2008	&	mon6	==1	&	st25==1
replace unemp=	7	if	year==	2008	&	mon7	==1	&	st25==1
replace unemp=	7.1	if	year==	2008	&	mon8	==1	&	st25==1
replace unemp=	7.2	if	year==	2008	&	mon9	==1	&	st25==1
replace unemp=	7.3	if	year==	2008	&	mon10	==1	&	st25==1
replace unemp=	7.5	if	year==	2008	&	mon11	==1	&	st25==1
replace unemp=	7.8	if	year==	2008	&	mon12	==1	&	st25==1
replace unemp=	8.2	if	year==	2009	&	mon1	==1	&	st25==1
replace unemp=	8.6	if	year==	2009	&	mon2	==1	&	st25==1
replace unemp=	8.9	if	year==	2009	&	mon3	==1	&	st25==1
replace unemp=	9.2	if	year==	2009	&	mon4	==1	&	st25==1
replace unemp=	9.4	if	year==	2009	&	mon5	==1	&	st25==1
replace unemp=	9.6	if	year==	2009	&	mon6	==1	&	st25==1
replace unemp=	9.7	if	year==	2009	&	mon7	==1	&	st25==1
replace unemp=	9.9	if	year==	2009	&	mon8	==1	&	st25==1
replace unemp=	10.2	if	year==	2009	&	mon9	==1	&	st25==1
replace unemp=	10.4	if	year==	2009	&	mon10	==1	&	st25==1
replace unemp=	10.7	if	year==	2009	&	mon11	==1	&	st25==1
replace unemp=	10.9	if	year==	2009	&	mon12	==1	&	st25==1

replace unemp=	11		if	year==	2010	&	mon1	==1	&	st25==1
replace unemp=	11		if	year==	2010	&	mon2	==1	&	st25==1
replace unemp=	10.8		if	year==	2010	&	mon3	==1	&	st25==1
replace unemp=	10.6		if	year==	2010	&	mon4	==1	&	st25==1
replace unemp=	10.4		if	year==	2010	&	mon5	==1	&	st25==1
replace unemp=	10.3		if	year==	2010	&	mon6	==1	&	st25==1
replace unemp=	10.2		if	year==	2010	&	mon7	==1	&	st25==1
replace unemp=	10.1		if	year==	2010	&	mon8	==1	&	st25==1
replace unemp=	10.1	if	year==	2010	&	mon9	==1	&	st25==1
replace unemp=	10.2	if	year==	2010	&	mon10	==1	&	st25==1
replace unemp=	10.2	if	year==	2010	&	mon11	==1	&	st25==1
replace unemp=	10.2	if	year==	2010	&	mon12	==1	&	st25==1

replace unemp=	3.1	if	year==	2007	&	mon1	==1	&	st27==1
replace unemp=	3.1	if	year==	2007	&	mon2	==1	&	st27==1
replace unemp=	3.1	if	year==	2007	&	mon3	==1	&	st27==1
replace unemp=	3.2	if	year==	2007	&	mon4	==1	&	st27==1
replace unemp=	3.2	if	year==	2007	&	mon5	==1	&	st27==1
replace unemp=	3.3	if	year==	2007	&	mon6	==1	&	st27==1
replace unemp=	3.3	if	year==	2007	&	mon7	==1	&	st27==1
replace unemp=	3.4	if	year==	2007	&	mon8	==1	&	st27==1
replace unemp=	3.4	if	year==	2007	&	mon9	==1	&	st27==1
replace unemp=	3.5	if	year==	2007	&	mon10	==1	&	st27==1
replace unemp=	3.6	if	year==	2007	&	mon11	==1	&	st27==1
replace unemp=	3.6	if	year==	2007	&	mon12	==1	&	st27==1
replace unemp=	3.7	if	year==	2008	&	mon1	==1	&	st27==1
replace unemp=	3.8	if	year==	2008	&	mon2	==1	&	st27==1
replace unemp=	3.9	if	year==	2008	&	mon3	==1	&	st27==1
replace unemp=	4.1	if	year==	2008	&	mon4	==1	&	st27==1
replace unemp=	4.2	if	year==	2008	&	mon5	==1	&	st27==1
replace unemp=	4.4	if	year==	2008	&	mon6	==1	&	st27==1
replace unemp=	4.6	if	year==	2008	&	mon7	==1	&	st27==1
replace unemp=	4.8	if	year==	2008	&	mon8	==1	&	st27==1
replace unemp=	4.9	if	year==	2008	&	mon9	==1	&	st27==1
replace unemp=	5.1	if	year==	2008	&	mon10	==1	&	st27==1
replace unemp=	5.3	if	year==	2008	&	mon11	==1	&	st27==1
replace unemp=	5.4	if	year==	2008	&	mon12	==1	&	st27==1
replace unemp=	5.6	if	year==	2009	&	mon1	==1	&	st27==1
replace unemp=	5.7	if	year==	2009	&	mon2	==1	&	st27==1
replace unemp=	5.8	if	year==	2009	&	mon3	==1	&	st27==1
replace unemp=	5.9	if	year==	2009	&	mon4	==1	&	st27==1
replace unemp=	6.1	if	year==	2009	&	mon5	==1	&	st27==1
replace unemp=	6.2	if	year==	2009	&	mon6	==1	&	st27==1
replace unemp=	6.4	if	year==	2009	&	mon7	==1	&	st27==1
replace unemp=	6.6	if	year==	2009	&	mon8	==1	&	st27==1
replace unemp=	6.7	if	year==	2009	&	mon9	==1	&	st27==1
replace unemp=	6.8	if	year==	2009	&	mon10	==1	&	st27==1
replace unemp=	6.9	if	year==	2009	&	mon11	==1	&	st27==1
replace unemp=	7	if	year==	2009	&	mon12	==1	&	st27==1


replace unemp=	7	if	year==	2010	&	mon1	==1	&	st27==1
replace unemp=	7.1	if	year==	2010	&	mon2	==1	&	st27==1
replace unemp=	7.1	if	year==	2010	&	mon3	==1	&	st27==1
replace unemp=	7.1	if	year==	2010	&	mon4	==1	&	st27==1
replace unemp=	7.2	if	year==	2010	&	mon5	==1	&	st27==1
replace unemp=	7.2	if	year==	2010	&	mon6	==1	&	st27==1
replace unemp=	7.3	if	year==	2010	&	mon7	==1	&	st27==1
replace unemp=	7.3	if	year==	2010	&	mon8	==1	&	st27==1
replace unemp=	7.3	if	year==	2010	&	mon9	==1	&	st27==1
replace unemp=	7.4	if	year==	2010	&	mon10	==1	&	st27==1
replace unemp=	7.4	if	year==	2010	&	mon11	==1	&	st27==1
replace unemp=	7.4	if	year==	2010	&	mon12	==1	&	st27==1


replace unemp=	4.7	if	year==	2007	&	mon1	==1	&	st26==1
replace unemp=	4.7	if	year==	2007	&	mon2	==1	&	st26==1
replace unemp=	4.7	if	year==	2007	&	mon3	==1	&	st26==1
replace unemp=	4.7	if	year==	2007	&	mon4	==1	&	st26==1
replace unemp=	4.9	if	year==	2007	&	mon5	==1	&	st26==1
replace unemp=	5	if	year==	2007	&	mon6	==1	&	st26==1
replace unemp=	5.2	if	year==	2007	&	mon7	==1	&	st26==1
replace unemp=	5.3	if	year==	2007	&	mon8	==1	&	st26==1
replace unemp=	5.4	if	year==	2007	&	mon9	==1	&	st26==1
replace unemp=	5.4	if	year==	2007	&	mon10	==1	&	st26==1
replace unemp=	5.4	if	year==	2007	&	mon11	==1	&	st26==1
replace unemp=	5.3	if	year==	2007	&	mon12	==1	&	st26==1
replace unemp=	5.3	if	year==	2008	&	mon1	==1	&	st26==1
replace unemp=	5.2	if	year==	2008	&	mon2	==1	&	st26==1
replace unemp=	5.3	if	year==	2008	&	mon3	==1	&	st26==1
replace unemp=	5.4	if	year==	2008	&	mon4	==1	&	st26==1
replace unemp=	5.6	if	year==	2008	&	mon5	==1	&	st26==1
replace unemp=	5.9	if	year==	2008	&	mon6	==1	&	st26==1
replace unemp=	6.1	if	year==	2008	&	mon7	==1	&	st26==1
replace unemp=	6.3	if	year==	2008	&	mon8	==1	&	st26==1
replace unemp=	6.5	if	year==	2008	&	mon9	==1	&	st26==1
replace unemp=	6.8	if	year==	2008	&	mon10	==1	&	st26==1
replace unemp=	7.2	if	year==	2008	&	mon11	==1	&	st26==1
replace unemp=	7.6	if	year==	2008	&	mon12	==1	&	st26==1
replace unemp=	8	if	year==	2009	&	mon1	==1	&	st26==1
replace unemp=	8.4	if	year==	2009	&	mon2	==1	&	st26==1
replace unemp=	8.8	if	year==	2009	&	mon3	==1	&	st26==1
replace unemp=	9	if	year==	2009	&	mon4	==1	&	st26==1
replace unemp=	9.3	if	year==	2009	&	mon5	==1	&	st26==1
replace unemp=	9.5	if	year==	2009	&	mon6	==1	&	st26==1
replace unemp=	9.6	if	year==	2009	&	mon7	==1	&	st26==1
replace unemp=	9.7	if	year==	2009	&	mon8	==1	&	st26==1
replace unemp=	9.7	if	year==	2009	&	mon9	==1	&	st26==1
replace unemp=	9.7	if	year==	2009	&	mon10	==1	&	st26==1
replace unemp=	9.7	if	year==	2009	&	mon11	==1	&	st26==1
replace unemp=	9.7	if	year==	2009	&	mon12	==1	&	st26==1

replace unemp=	9.7	if	year==	2010	&	mon1	==1	&	st26==1
replace unemp=	9.6	if	year==	2010	&	mon2	==1	&	st26==1
replace unemp=	9.6	if	year==	2010	&	mon3	==1	&	st26==1
replace unemp=	9.5	if	year==	2010	&	mon4	==1	&	st26==1
replace unemp=	9.5	if	year==	2010	&	mon5	==1	&	st26==1
replace unemp=	9.5	if	year==	2010	&	mon6	==1	&	st26==1
replace unemp=	9.5	if	year==	2010	&	mon7	==1	&	st26==1
replace unemp=	9.6	if	year==	2010	&	mon8	==1	&	st26==1
replace unemp=	9.6	if	year==	2010	&	mon9	==1	&	st26==1
replace unemp=	9.6	if	year==	2010	&	mon10	==1	&	st26==1
replace unemp=	9.6	if	year==	2010	&	mon11	==1	&	st26==1
replace unemp=	9.6	if	year==	2010	&	mon12	==1	&	st26==1


replace unemp=	2.8	if	year==	2007	&	mon1	==1	&	st28==1
replace unemp=	2.8	if	year==	2007	&	mon2	==1	&	st28==1
replace unemp=	2.7	if	year==	2007	&	mon3	==1	&	st28==1
replace unemp=	2.8	if	year==	2007	&	mon4	==1	&	st28==1
replace unemp=	2.9	if	year==	2007	&	mon5	==1	&	st28==1
replace unemp=	3	if	year==	2007	&	mon6	==1	&	st28==1
replace unemp=	3.1	if	year==	2007	&	mon7	==1	&	st28==1
replace unemp=	3.1	if	year==	2007	&	mon8	==1	&	st28==1
replace unemp=	3.1	if	year==	2007	&	mon9	==1	&	st28==1
replace unemp=	3	if	year==	2007	&	mon10	==1	&	st28==1
replace unemp=	2.9	if	year==	2007	&	mon11	==1	&	st28==1
replace unemp=	2.9	if	year==	2007	&	mon12	==1	&	st28==1
replace unemp=	2.8	if	year==	2008	&	mon1	==1	&	st28==1
replace unemp=	2.8	if	year==	2008	&	mon2	==1	&	st28==1
replace unemp=	2.9	if	year==	2008	&	mon3	==1	&	st28==1
replace unemp=	2.9	if	year==	2008	&	mon4	==1	&	st28==1
replace unemp=	3	if	year==	2008	&	mon5	==1	&	st28==1
replace unemp=	3.1	if	year==	2008	&	mon6	==1	&	st28==1
replace unemp=	3.2	if	year==	2008	&	mon7	==1	&	st28==1
replace unemp=	3.3	if	year==	2008	&	mon8	==1	&	st28==1
replace unemp=	3.4	if	year==	2008	&	mon9	==1	&	st28==1
replace unemp=	3.5	if	year==	2008	&	mon10	==1	&	st28==1
replace unemp=	3.6	if	year==	2008	&	mon11	==1	&	st28==1
replace unemp=	3.8	if	year==	2008	&	mon12	==1	&	st28==1
replace unemp=	4.1	if	year==	2009	&	mon1	==1	&	st28==1
replace unemp=	4.3	if	year==	2009	&	mon2	==1	&	st28==1
replace unemp=	4.5	if	year==	2009	&	mon3	==1	&	st28==1
replace unemp=	4.7	if	year==	2009	&	mon4	==1	&	st28==1
replace unemp=	4.9	if	year==	2009	&	mon5	==1	&	st28==1
replace unemp=	5	if	year==	2009	&	mon6	==1	&	st28==1
replace unemp=	5	if	year==	2009	&	mon7	==1	&	st28==1
replace unemp=	5	if	year==	2009	&	mon8	==1	&	st28==1
replace unemp=	5	if	year==	2009	&	mon9	==1	&	st28==1
replace unemp=	5	if	year==	2009	&	mon10	==1	&	st28==1
replace unemp=	5	if	year==	2009	&	mon11	==1	&	st28==1
replace unemp=	5	if	year==	2009	&	mon12	==1	&	st28==1

replace unemp=	5	if	year==	2010	&	mon1	==1	&	st28==1
replace unemp=	4.9	if	year==	2010	&	mon2	==1	&	st28==1
replace unemp=	4.9	if	year==	2010	&	mon3	==1	&	st28==1
replace unemp=	4.8	if	year==	2010	&	mon4	==1	&	st28==1
replace unemp=	4.7	if	year==	2010	&	mon5	==1	&	st28==1
replace unemp=	4.6	if	year==	2010	&	mon6	==1	&	st28==1
replace unemp=	4.6	if	year==	2010	&	mon7	==1	&	st28==1
replace unemp=	4.5	if	year==	2010	&	mon8	==1	&	st28==1
replace unemp=	4.5	if	year==	2010	&	mon9	==1	&	st28==1
replace unemp=	4.4	if	year==	2010	&	mon10	==1	&	st28==1
replace unemp=	4.4	if	year==	2010	&	mon11	==1	&	st28==1
replace unemp=	4.3	if	year==	2010	&	mon12	==1	&	st28==1


replace unemp=	4.2	if	year==	2007	&	mon1	==1	&	st29==1
replace unemp=	4.3	if	year==	2007	&	mon2	==1	&	st29==1
replace unemp=	4.3	if	year==	2007	&	mon3	==1	&	st29==1
replace unemp=	4.3	if	year==	2007	&	mon4	==1	&	st29==1
replace unemp=	4.4	if	year==	2007	&	mon5	==1	&	st29==1
replace unemp=	4.5	if	year==	2007	&	mon6	==1	&	st29==1
replace unemp=	4.6	if	year==	2007	&	mon7	==1	&	st29==1
replace unemp=	4.7	if	year==	2007	&	mon8	==1	&	st29==1
replace unemp=	4.8	if	year==	2007	&	mon9	==1	&	st29==1
replace unemp=	4.8	if	year==	2007	&	mon10	==1	&	st29==1
replace unemp=	4.9	if	year==	2007	&	mon11	==1	&	st29==1
replace unemp=	5	if	year==	2007	&	mon12	==1	&	st29==1
replace unemp=	5	if	year==	2008	&	mon1	==1	&	st29==1
replace unemp=	5.1	if	year==	2008	&	mon2	==1	&	st29==1
replace unemp=	5.3	if	year==	2008	&	mon3	==1	&	st29==1
replace unemp=	5.5	if	year==	2008	&	mon4	==1	&	st29==1
replace unemp=	5.9	if	year==	2008	&	mon5	==1	&	st29==1
replace unemp=	6.2	if	year==	2008	&	mon6	==1	&	st29==1
replace unemp=	6.7	if	year==	2008	&	mon7	==1	&	st29==1
replace unemp=	7.1	if	year==	2008	&	mon8	==1	&	st29==1
replace unemp=	7.6	if	year==	2008	&	mon9	==1	&	st29==1
replace unemp=	8.1	if	year==	2008	&	mon10	==1	&	st29==1
replace unemp=	8.7		if	year==	2008	&	mon11	==1	&	st29==1
replace unemp=	9.3		if	year==	2008	&	mon12	==1	&	st29==1
replace unemp=	9.9		if	year==	2009	&	mon1	==1	&	st29==1
replace unemp=	10.4	if	year==	2009	&	mon2	==1	&	st29==1
replace unemp=	10.9	if	year==	2009	&	mon3	==1	&	st29==1
replace unemp=	11.4	if	year==	2009	&	mon4	==1	&	st29==1
replace unemp=	12		if	year==	2009	&	mon5	==1	&	st29==1
replace unemp=	12.5	if	year==	2009	&	mon6	==1	&	st29==1
replace unemp=	13		if	year==	2009	&	mon7	==1	&	st29==1
replace unemp=	13.5	if	year==	2009	&	mon8	==1	&	st29==1
replace unemp=	13.8	if	year==	2009	&	mon9	==1	&	st29==1
replace unemp=	14.1	if	year==	2009	&	mon10	==1	&	st29==1
replace unemp=	14.3	if	year==	2009	&	mon11	==1	&	st29==1
replace unemp=	14.5	if	year==	2009	&	mon12	==1	&	st29==1

replace unemp=	14.6		if	year==	2010	&	mon1	==1	&	st29==1
replace unemp=	14.7	if	year==	2010	&	mon2	==1	&	st29==1
replace unemp=	14.8	if	year==	2010	&	mon3	==1	&	st29==1
replace unemp=	14.9	if	year==	2010	&	mon4	==1	&	st29==1
replace unemp=	14.9		if	year==	2010	&	mon5	==1	&	st29==1
replace unemp=	14.9	if	year==	2010	&	mon6	==1	&	st29==1
replace unemp=	14.9	if	year==	2010	&	mon7	==1	&	st29==1
replace unemp=	14.9	if	year==	2010	&	mon8	==1	&	st29==1
replace unemp=	14.9	if	year==	2010	&	mon9	==1	&	st29==1
replace unemp=	14.9	if	year==	2010	&	mon10	==1	&	st29==1
replace unemp=	14.9	if	year==	2010	&	mon11	==1	&	st29==1
replace unemp=	14.9	if	year==	2010	&	mon12	==1	&	st29==1

replace unemp=	3.7	if	year==	2007	&	mon1	==1	&	st30==1
replace unemp=	3.7	if	year==	2007	&	mon2	==1	&	st30==1
replace unemp=	3.6	if	year==	2007	&	mon3	==1	&	st30==1
replace unemp=	3.6	if	year==	2007	&	mon4	==1	&	st30==1
replace unemp=	3.6	if	year==	2007	&	mon5	==1	&	st30==1
replace unemp=	3.6	if	year==	2007	&	mon6	==1	&	st30==1
replace unemp=	3.5	if	year==	2007	&	mon7	==1	&	st30==1
replace unemp=	3.5	if	year==	2007	&	mon8	==1	&	st30==1
replace unemp=	3.4	if	year==	2007	&	mon9	==1	&	st30==1
replace unemp=	3.4	if	year==	2007	&	mon10	==1	&	st30==1
replace unemp=	3.4	if	year==	2007	&	mon11	==1	&	st30==1
replace unemp=	3.4	if	year==	2007	&	mon12	==1	&	st30==1
replace unemp=	3.5	if	year==	2008	&	mon1	==1	&	st30==1
replace unemp=	3.5	if	year==	2008	&	mon2	==1	&	st30==1
replace unemp=	3.5	if	year==	2008	&	mon3	==1	&	st30==1
replace unemp=	3.6	if	year==	2008	&	mon4	==1	&	st30==1
replace unemp=	3.7	if	year==	2008	&	mon5	==1	&	st30==1
replace unemp=	3.8	if	year==	2008	&	mon6	==1	&	st30==1
replace unemp=	3.9	if	year==	2008	&	mon7	==1	&	st30==1
replace unemp=	4	if	year==	2008	&	mon8	==1	&	st30==1
replace unemp=	4.1	if	year==	2008	&	mon9	==1	&	st30==1
replace unemp=	4.3	if	year==	2008	&	mon10	==1	&	st30==1
replace unemp=	4.5	if	year==	2008	&	mon11	==1	&	st30==1
replace unemp=	4.8	if	year==	2008	&	mon12	==1	&	st30==1
replace unemp=	5.2	if	year==	2009	&	mon1	==1	&	st30==1
replace unemp=	5.5	if	year==	2009	&	mon2	==1	&	st30==1
replace unemp=	5.8	if	year==	2009	&	mon3	==1	&	st30==1
replace unemp=	6.1	if	year==	2009	&	mon4	==1	&	st30==1
replace unemp=	6.2	if	year==	2009	&	mon5	==1	&	st30==1
replace unemp=	6.4	if	year==	2009	&	mon6	==1	&	st30==1
replace unemp=	6.5	if	year==	2009	&	mon7	==1	&	st30==1
replace unemp=	6.6	if	year==	2009	&	mon8	==1	&	st30==1
replace unemp=	6.7	if	year==	2009	&	mon9	==1	&	st30==1
replace unemp=	6.7	if	year==	2009	&	mon10	==1	&	st30==1
replace unemp=	6.7	if	year==	2009	&	mon11	==1	&	st30==1
replace unemp=	6.7	if	year==	2009	&	mon12	==1	&	st30==1


replace unemp=	6.7	if	year==	2010	&	mon1	==1	&	st30==1
replace unemp=	6.6	if	year==	2010	&	mon2	==1	&	st30==1
replace unemp=	6.4	if	year==	2010	&	mon3	==1	&	st30==1
replace unemp=	6.3	if	year==	2010	&	mon4	==1	&	st30==1
replace unemp=	6.1	if	year==	2010	&	mon5	==1	&	st30==1
replace unemp=	6	if	year==	2010	&	mon6	==1	&	st30==1
replace unemp=	5.9	if	year==	2010	&	mon7	==1	&	st30==1
replace unemp=	5.8	if	year==	2010	&	mon8	==1	&	st30==1
replace unemp=	5.8	if	year==	2010	&	mon9	==1	&	st30==1
replace unemp=	5.7	if	year==	2010	&	mon10	==1	&	st30==1
replace unemp=	5.7	if	year==	2010	&	mon11	==1	&	st30==1
replace unemp=	5.6	if	year==	2010	&	mon12	==1	&	st30==1



replace unemp=	4.2	if	year==	2007	&	mon1	==1	&	st31==1
replace unemp=	4.2	if	year==	2007	&	mon2	==1	&	st31==1
replace unemp=	4.1	if	year==	2007	&	mon3	==1	&	st31==1
replace unemp=	4.2	if	year==	2007	&	mon4	==1	&	st31==1
replace unemp=	4.2	if	year==	2007	&	mon5	==1	&	st31==1
replace unemp=	4.2	if	year==	2007	&	mon6	==1	&	st31==1
replace unemp=	4.3	if	year==	2007	&	mon7	==1	&	st31==1
replace unemp=	4.3	if	year==	2007	&	mon8	==1	&	st31==1
replace unemp=	4.3	if	year==	2007	&	mon9	==1	&	st31==1
replace unemp=	4.4	if	year==	2007	&	mon10	==1	&	st31==1
replace unemp=	4.5	if	year==	2007	&	mon11	==1	&	st31==1
replace unemp=	4.5	if	year==	2007	&	mon12	==1	&	st31==1
replace unemp=	4.6	if	year==	2008	&	mon1	==1	&	st31==1
replace unemp=	4.7	if	year==	2008	&	mon2	==1	&	st31==1
replace unemp=	4.8	if	year==	2008	&	mon3	==1	&	st31==1
replace unemp=	4.9	if	year==	2008	&	mon4	==1	&	st31==1
replace unemp=	5	if	year==	2008	&	mon5	==1	&	st31==1
replace unemp=	5.2	if	year==	2008	&	mon6	==1	&	st31==1
replace unemp=	5.4	if	year==	2008	&	mon7	==1	&	st31==1
replace unemp=	5.6	if	year==	2008	&	mon8	==1	&	st31==1
replace unemp=	5.8	if	year==	2008	&	mon9	==1	&	st31==1
replace unemp=	6.1	if	year==	2008	&	mon10	==1	&	st31==1
replace unemp=	6.5	if	year==	2008	&	mon11	==1	&	st31==1
replace unemp=	7	if	year==	2008	&	mon12	==1	&	st31==1
replace unemp=	7.5	if	year==	2009	&	mon1	==1	&	st31==1
replace unemp=	8	if	year==	2009	&	mon2	==1	&	st31==1
replace unemp=	8.4	if	year==	2009	&	mon3	==1	&	st31==1
replace unemp=	8.8	if	year==	2009	&	mon4	==1	&	st31==1
replace unemp=	9	if	year==	2009	&	mon5	==1	&	st31==1
replace unemp=	9.3	if	year==	2009	&	mon6	==1	&	st31==1
replace unemp=	9.4	if	year==	2009	&	mon7	==1	&	st31==1
replace unemp=	9.5	if	year==	2009	&	mon8	==1	&	st31==1
replace unemp=	9.6	if	year==	2009	&	mon9	==1	&	st31==1
replace unemp=	9.7	if	year==	2009	&	mon10	==1	&	st31==1
replace unemp=	9.7	if	year==	2009	&	mon11	==1	&	st31==1
replace unemp=	9.7	if	year==	2009	&	mon12	==1	&	st31==1

replace unemp=	9.8	if	year==	2010	&	mon1	==1	&	st31==1
replace unemp=	9.7	if	year==	2010	&	mon2	==1	&	st31==1
replace unemp=	9.7	if	year==	2010	&	mon3	==1	&	st31==1
replace unemp=	9.6	if	year==	2010	&	mon4	==1	&	st31==1
replace unemp=	9.5	if	year==	2010	&	mon5	==1	&	st31==1
replace unemp=	9.5	if	year==	2010	&	mon6	==1	&	st31==1
replace unemp=	9.4	if	year==	2010	&	mon7	==1	&	st31==1
replace unemp=	9.3	if	year==	2010	&	mon8	==1	&	st31==1
replace unemp=	9.3	if	year==	2010	&	mon9	==1	&	st31==1
replace unemp=	9.2	if	year==	2010	&	mon10	==1	&	st31==1
replace unemp=	9.2	if	year==	2010	&	mon11	==1	&	st31==1
replace unemp=	9.1	if	year==	2010	&	mon12	==1	&	st31==1


replace unemp=	4.6	if	year==	2007	&	mon1	==1	&	st34==1
replace unemp=	4.6	if	year==	2007	&	mon2	==1	&	st34==1
replace unemp=	4.5	if	year==	2007	&	mon3	==1	&	st34==1
replace unemp=	4.6	if	year==	2007	&	mon4	==1	&	st34==1
replace unemp=	4.6	if	year==	2007	&	mon5	==1	&	st34==1
replace unemp=	4.7	if	year==	2007	&	mon6	==1	&	st34==1
replace unemp=	4.8	if	year==	2007	&	mon7	==1	&	st34==1
replace unemp=	4.8	if	year==	2007	&	mon8	==1	&	st34==1
replace unemp=	4.9	if	year==	2007	&	mon9	==1	&	st34==1
replace unemp=	4.9	if	year==	2007	&	mon10	==1	&	st34==1
replace unemp=	4.9	if	year==	2007	&	mon11	==1	&	st34==1
replace unemp=	5	if	year==	2007	&	mon12	==1	&	st34==1
replace unemp=	5	if	year==	2008	&	mon1	==1	&	st34==1
replace unemp=	5	if	year==	2008	&	mon2	==1	&	st34==1
replace unemp=	5.2	if	year==	2008	&	mon3	==1	&	st34==1
replace unemp=	5.3	if	year==	2008	&	mon4	==1	&	st34==1
replace unemp=	5.7	if	year==	2008	&	mon5	==1	&	st34==1
replace unemp=	6	if	year==	2008	&	mon6	==1	&	st34==1
replace unemp=	6.3	if	year==	2008	&	mon7	==1	&	st34==1
replace unemp=	6.6	if	year==	2008	&	mon8	==1	&	st34==1
replace unemp=	6.8	if	year==	2008	&	mon9	==1	&	st34==1
replace unemp=	7.3	if	year==	2008	&	mon10	==1	&	st34==1
replace unemp=	7.8	if	year==	2008	&	mon11	==1	&	st34==1
replace unemp=	8.5	if	year==	2008	&	mon12	==1	&	st34==1
replace unemp=	9.2	if	year==	2009	&	mon1	==1	&	st34==1
replace unemp=	9.9	if	year==	2009	&	mon2	==1	&	st34==1
replace unemp=	10.4	if	year==	2009	&	mon3	==1	&	st34==1
replace unemp=	10.7	if	year==	2009	&	mon4	==1	&	st34==1
replace unemp=	11	if	year==	2009	&	mon5	==1	&	st34==1
replace unemp=	11	if	year==	2009	&	mon6	==1	&	st34==1
replace unemp=	11.1	if	year==	2009	&	mon7	==1	&	st34==1
replace unemp=	11	if	year==	2009	&	mon8	==1	&	st34==1
replace unemp=	11	if	year==	2009	&	mon9	==1	&	st34==1
replace unemp=	11.1	if	year==	2009	&	mon10	==1	&	st34==1
replace unemp=	11.2	if	year==	2009	&	mon11	==1	&	st34==1
replace unemp=	11.3	if	year==	2009	&	mon12	==1	&	st34==1

replace unemp=	11.4		if	year==	2010	&	mon1	==1	&	st34==1
replace unemp=	11.4		if	year==	2010	&	mon2	==1	&	st34==1
replace unemp=	11.3	if	year==	2010	&	mon3	==1	&	st34==1
replace unemp=	11.1	if	year==	2010	&	mon4	==1	&	st34==1
replace unemp=	10.8	if	year==	2010	&	mon5	==1	&	st34==1
replace unemp=	10.5	if	year==	2010	&	mon6	==1	&	st34==1
replace unemp=	10.3	if	year==	2010	&	mon7	==1	&	st34==1
replace unemp=	10.1	if	year==	2010	&	mon8	==1	&	st34==1
replace unemp=	10		if	year==	2010	&	mon9	==1	&	st34==1
replace unemp=	9.9		if	year==	2010	&	mon10	==1	&	st34==1
replace unemp=	9.8		if	year==	2010	&	mon11	==1	&	st34==1
replace unemp=	9.8		if	year==	2010	&	mon12	==1	&	st34==1



replace unemp=	4.1	if	year==	2007	&	mon1	==1	&	st33==1
replace unemp=	4	if	year==	2007	&	mon2	==1	&	st33==1
replace unemp=	4	if	year==	2007	&	mon3	==1	&	st33==1
replace unemp=	4.1	if	year==	2007	&	mon4	==1	&	st33==1
replace unemp=	4.1	if	year==	2007	&	mon5	==1	&	st33==1
replace unemp=	4.2	if	year==	2007	&	mon6	==1	&	st33==1
replace unemp=	4.3	if	year==	2007	&	mon7	==1	&	st33==1
replace unemp=	4.4	if	year==	2007	&	mon8	==1	&	st33==1
replace unemp=	4.4	if	year==	2007	&	mon9	==1	&	st33==1
replace unemp=	4.5	if	year==	2007	&	mon10	==1	&	st33==1
replace unemp=	4.5	if	year==	2007	&	mon11	==1	&	st33==1
replace unemp=	4.6	if	year==	2007	&	mon12	==1	&	st33==1
replace unemp=	4.7	if	year==	2008	&	mon1	==1	&	st33==1
replace unemp=	4.7	if	year==	2008	&	mon2	==1	&	st33==1
replace unemp=	4.8	if	year==	2008	&	mon3	==1	&	st33==1
replace unemp=	4.8	if	year==	2008	&	mon4	==1	&	st33==1
replace unemp=	5	if	year==	2008	&	mon5	==1	&	st33==1
replace unemp=	5.1	if	year==	2008	&	mon6	==1	&	st33==1
replace unemp=	5.3	if	year==	2008	&	mon7	==1	&	st33==1
replace unemp=	5.4	if	year==	2008	&	mon8	==1	&	st33==1
replace unemp=	5.6	if	year==	2008	&	mon9	==1	&	st33==1
replace unemp=	5.8	if	year==	2008	&	mon10	==1	&	st33==1
replace unemp=	6.1	if	year==	2008	&	mon11	==1	&	st33==1
replace unemp=	6.5	if	year==	2008	&	mon12	==1	&	st33==1
replace unemp=	6.9	if	year==	2009	&	mon1	==1	&	st33==1
replace unemp=	7.2	if	year==	2009	&	mon2	==1	&	st33==1
replace unemp=	7.5	if	year==	2009	&	mon3	==1	&	st33==1
replace unemp=	7.7	if	year==	2009	&	mon4	==1	&	st33==1
replace unemp=	7.9	if	year==	2009	&	mon5	==1	&	st33==1
replace unemp=	8	if	year==	2009	&	mon6	==1	&	st33==1
replace unemp=	8	if	year==	2009	&	mon7	==1	&	st33==1
replace unemp=	8.1	if	year==	2009	&	mon8	==1	&	st33==1
replace unemp=	8.1	if	year==	2009	&	mon9	==1	&	st33==1
replace unemp=	8.1	if	year==	2009	&	mon10	==1	&	st33==1
replace unemp=	8.1	if	year==	2009	&	mon11	==1	&	st33==1
replace unemp=	8.1	if	year==	2009	&	mon12	==1	&	st33==1

replace unemp=	8.1	if	year==	2010	&	mon1	==1	&	st33==1
replace unemp=	8.1	if	year==	2010	&	mon2	==1	&	st33==1
replace unemp=	8	if	year==	2010	&	mon3	==1	&	st33==1
replace unemp=	8	if	year==	2010	&	mon4	==1	&	st33==1
replace unemp=	7.9	if	year==	2010	&	mon5	==1	&	st33==1
replace unemp=	7.9	if	year==	2010	&	mon6	==1	&	st33==1
replace unemp=	7.9	if	year==	2010	&	mon7	==1	&	st33==1
replace unemp=	7.9	if	year==	2010	&	mon8	==1	&	st33==1
replace unemp=	7.8	if	year==	2010	&	mon9	==1	&	st33==1
replace unemp=	7.8	if	year==	2010	&	mon10	==1	&	st33==1
replace unemp=	7.8	if	year==	2010	&	mon11	==1	&	st33==1
replace unemp=	7.8	if	year==	2010	&	mon12	==1	&	st33==1

replace unemp=	3.5	if	year==	2007	&	mon1	==1	&	st32==1
replace unemp=	3.5	if	year==	2007	&	mon2	==1	&	st32==1
replace unemp=	3.4	if	year==	2007	&	mon3	==1	&	st32==1
replace unemp=	3.4	if	year==	2007	&	mon4	==1	&	st32==1
replace unemp=	3.4	if	year==	2007	&	mon5	==1	&	st32==1
replace unemp=	3.4	if	year==	2007	&	mon6	==1	&	st32==1
replace unemp=	3.4	if	year==	2007	&	mon7	==1	&	st32==1
replace unemp=	3.4	if	year==	2007	&	mon8	==1	&	st32==1
replace unemp=	3.4	if	year==	2007	&	mon9	==1	&	st32==1
replace unemp=	3.4	if	year==	2007	&	mon10	==1	&	st32==1
replace unemp=	3.4	if	year==	2007	&	mon11	==1	&	st32==1
replace unemp=	3.5	if	year==	2007	&	mon12	==1	&	st32==1
replace unemp=	3.5	if	year==	2008	&	mon1	==1	&	st32==1
replace unemp=	3.6	if	year==	2008	&	mon2	==1	&	st32==1
replace unemp=	3.8	if	year==	2008	&	mon3	==1	&	st32==1
replace unemp=	3.9	if	year==	2008	&	mon4	==1	&	st32==1
replace unemp=	4.1	if	year==	2008	&	mon5	==1	&	st32==1
replace unemp=	4.3	if	year==	2008	&	mon6	==1	&	st32==1
replace unemp=	4.5	if	year==	2008	&	mon7	==1	&	st32==1
replace unemp=	4.7	if	year==	2008	&	mon8	==1	&	st32==1
replace unemp=	4.9	if	year==	2008	&	mon9	==1	&	st32==1
replace unemp=	5.2	if	year==	2008	&	mon10	==1	&	st32==1
replace unemp=	5.4	if	year==	2008	&	mon11	==1	&	st32==1
replace unemp=	5.6	if	year==	2008	&	mon12	==1	&	st32==1
replace unemp=	5.8	if	year==	2009	&	mon1	==1	&	st32==1
replace unemp=	6	if	year==	2009	&	mon2	==1	&	st32==1
replace unemp=	6.2	if	year==	2009	&	mon3	==1	&	st32==1
replace unemp=	6.4	if	year==	2009	&	mon4	==1	&	st32==1
replace unemp=	6.7	if	year==	2009	&	mon5	==1	&	st32==1
replace unemp=	6.9	if	year==	2009	&	mon6	==1	&	st32==1
replace unemp=	7.2	if	year==	2009	&	mon7	==1	&	st32==1
replace unemp=	7.4	if	year==	2009	&	mon8	==1	&	st32==1
replace unemp=	7.6	if	year==	2009	&	mon9	==1	&	st32==1
replace unemp=	7.8	if	year==	2009	&	mon10	==1	&	st32==1
replace unemp=	7.9	if	year==	2009	&	mon11	==1	&	st32==1
replace unemp=	8	if	year==	2009	&	mon12	==1	&	st32==1

replace unemp=	8.1	if	year==	2010	&	mon1	==1	&	st32==1
replace unemp=	8.2	if	year==	2010	&	mon2	==1	&	st32==1
replace unemp=	8.2	if	year==	2010	&	mon3	==1	&	st32==1
replace unemp=	8.3	if	year==	2010	&	mon4	==1	&	st32==1
replace unemp=	8.3	if	year==	2010	&	mon5	==1	&	st32==1
replace unemp=	8.4	if	year==	2010	&	mon6	==1	&	st32==1
replace unemp=	8.5	if	year==	2010	&	mon7	==1	&	st32==1
replace unemp=	8.5	if	year==	2010	&	mon8	==1	&	st32==1
replace unemp=	8.6	if	year==	2010	&	mon9	==1	&	st32==1
replace unemp=	8.6	if	year==	2010	&	mon10	==1	&	st32==1
replace unemp=	8.6	if	year==	2010	&	mon11	==1	&	st32==1
replace unemp=	8.6	if	year==	2010	&	mon12	==1	&	st32==1


replace unemp=	3.1	if	year==	2007	&	mon1	==1	&	st35==1
replace unemp=	3.1	if	year==	2007	&	mon2	==1	&	st35==1
replace unemp=	3	if	year==	2007	&	mon3	==1	&	st35==1
replace unemp=	3.1	if	year==	2007	&	mon4	==1	&	st35==1
replace unemp=	3.1	if	year==	2007	&	mon5	==1	&	st35==1
replace unemp=	3.1	if	year==	2007	&	mon6	==1	&	st35==1
replace unemp=	3.2	if	year==	2007	&	mon7	==1	&	st35==1
replace unemp=	3.2	if	year==	2007	&	mon8	==1	&	st35==1
replace unemp=	3.2	if	year==	2007	&	mon9	==1	&	st35==1
replace unemp=	3.2	if	year==	2007	&	mon10	==1	&	st35==1
replace unemp=	3.1	if	year==	2007	&	mon11	==1	&	st35==1
replace unemp=	3	if	year==	2007	&	mon12	==1	&	st35==1
replace unemp=	2.9	if	year==	2008	&	mon1	==1	&	st35==1
replace unemp=	2.8	if	year==	2008	&	mon2	==1	&	st35==1
replace unemp=	2.8	if	year==	2008	&	mon3	==1	&	st35==1
replace unemp=	2.9	if	year==	2008	&	mon4	==1	&	st35==1
replace unemp=	3	if	year==	2008	&	mon5	==1	&	st35==1
replace unemp=	3.1	if	year==	2008	&	mon6	==1	&	st35==1
replace unemp=	3.2	if	year==	2008	&	mon7	==1	&	st35==1
replace unemp=	3.3	if	year==	2008	&	mon8	==1	&	st35==1
replace unemp=	3.3	if	year==	2008	&	mon9	==1	&	st35==1
replace unemp=	3.4	if	year==	2008	&	mon10	==1	&	st35==1
replace unemp=	3.5	if	year==	2008	&	mon11	==1	&	st35==1
replace unemp=	3.7	if	year==	2008	&	mon12	==1	&	st35==1
replace unemp=	3.9	if	year==	2009	&	mon1	==1	&	st35==1
replace unemp=	4.1	if	year==	2009	&	mon2	==1	&	st35==1
replace unemp=	4.3	if	year==	2009	&	mon3	==1	&	st35==1
replace unemp=	4.3	if	year==	2009	&	mon4	==1	&	st35==1
replace unemp=	4.3	if	year==	2009	&	mon5	==1	&	st35==1
replace unemp=	4.3	if	year==	2009	&	mon6	==1	&	st35==1
replace unemp=	4.3	if	year==	2009	&	mon7	==1	&	st35==1
replace unemp=	4.3	if	year==	2009	&	mon8	==1	&	st35==1
replace unemp=	4.2	if	year==	2009	&	mon9	==1	&	st35==1
replace unemp=	4.2	if	year==	2009	&	mon10	==1	&	st35==1
replace unemp=	4.2	if	year==	2009	&	mon11	==1	&	st35==1
replace unemp=	4.2	if	year==	2009	&	mon12	==1	&	st35==1


replace unemp=	4.1	if	year==	2010	&	mon1	==1	&	st35==1
replace unemp=	4.1	if	year==	2010	&	mon2	==1	&	st35==1
replace unemp=	4	if	year==	2010	&	mon3	==1	&	st35==1
replace unemp=	4	if	year==	2010	&	mon4	==1	&	st35==1
replace unemp=	3.9	if	year==	2010	&	mon5	==1	&	st35==1
replace unemp=	3.9	if	year==	2010	&	mon6	==1	&	st35==1
replace unemp=	3.9	if	year==	2010	&	mon7	==1	&	st35==1
replace unemp=	3.9	if	year==	2010	&	mon8	==1	&	st35==1
replace unemp=	3.9	if	year==	2010	&	mon9	==1	&	st35==1
replace unemp=	3.9	if	year==	2010	&	mon10	==1	&	st35==1
replace unemp=	3.9	if	year==	2010	&	mon11	==1	&	st35==1
replace unemp=	3.8	if	year==	2010	&	mon12	==1	&	st35==1


replace unemp=	5.3	if	year==	2007	&	mon1	==1	&	st36==1
replace unemp=	5.3	if	year==	2007	&	mon2	==1	&	st36==1
replace unemp=	5.3	if	year==	2007	&	mon3	==1	&	st36==1
replace unemp=	5.4	if	year==	2007	&	mon4	==1	&	st36==1
replace unemp=	5.5	if	year==	2007	&	mon5	==1	&	st36==1
replace unemp=	5.5	if	year==	2007	&	mon6	==1	&	st36==1
replace unemp=	5.6	if	year==	2007	&	mon7	==1	&	st36==1
replace unemp=	5.6	if	year==	2007	&	mon8	==1	&	st36==1
replace unemp=	5.7	if	year==	2007	&	mon9	==1	&	st36==1
replace unemp=	5.6	if	year==	2007	&	mon10	==1	&	st36==1
replace unemp=	5.6	if	year==	2007	&	mon11	==1	&	st36==1
replace unemp=	5.6	if	year==	2007	&	mon12	==1	&	st36==1
replace unemp=	5.5	if	year==	2008	&	mon1	==1	&	st36==1
replace unemp=	5.5	if	year==	2008	&	mon2	==1	&	st36==1
replace unemp=	5.6	if	year==	2008	&	mon3	==1	&	st36==1
replace unemp=	5.8	if	year==	2008	&	mon4	==1	&	st36==1
replace unemp=	6	if	year==	2008	&	mon5	==1	&	st36==1
replace unemp=	6.4	if	year==	2008	&	mon6	==1	&	st36==1
replace unemp=	6.7	if	year==	2008	&	mon7	==1	&	st36==1
replace unemp=	6.9	if	year==	2008	&	mon8	==1	&	st36==1
replace unemp=	7.1	if	year==	2008	&	mon9	==1	&	st36==1
replace unemp=	7.4	if	year==	2008	&	mon10	==1	&	st36==1
replace unemp=	7.7	if	year==	2008	&	mon11	==1	&	st36==1
replace unemp=	8.1	if	year==	2008	&	mon12	==1	&	st36==1
replace unemp=	8.6	if	year==	2009	&	mon1	==1	&	st36==1
replace unemp=	9.1	if	year==	2009	&	mon2	==1	&	st36==1
replace unemp=	9.6	if	year==	2009	&	mon3	==1	&	st36==1
replace unemp=	10	if	year==	2009	&	mon4	==1	&	st36==1
replace unemp=	10.4	if	year==	2009	&	mon5	==1	&	st36==1
replace unemp=	10.7	if	year==	2009	&	mon6	==1	&	st36==1
replace unemp=	10.9	if	year==	2009	&	mon7	==1	&	st36==1
replace unemp=	11		if	year==	2009	&	mon8	==1	&	st36==1
replace unemp=	11.1	if	year==	2009	&	mon9	==1	&	st36==1
replace unemp=	11.1	if	year==	2009	&	mon10	==1	&	st36==1
replace unemp=	11		if	year==	2009	&	mon11	==1	&	st36==1
replace unemp=	10.9	if	year==	2009	&	mon12	==1	&	st36==1


replace unemp=	10.8		if	year==	2010	&	mon1	==1	&	st36==1
replace unemp=	10.6		if	year==	2010	&	mon2	==1	&	st36==1
replace unemp=	10.5		if	year==	2010	&	mon3	==1	&	st36==1
replace unemp=	10.4		if	year==	2010	&	mon4	==1	&	st36==1
replace unemp=	10.3	if	year==	2010	&	mon5	==1	&	st36==1
replace unemp=	10.3	if	year==	2010	&	mon6	==1	&	st36==1
replace unemp=	10.2	if	year==	2010	&	mon7	==1	&	st36==1
replace unemp=	10.2	if	year==	2010	&	mon8	==1	&	st36==1
replace unemp=	10.1	if	year==	2010	&	mon9	==1	&	st36==1
replace unemp=	10.1	if	year==	2010	&	mon10	==1	&	st36==1
replace unemp=	10		if	year==	2010	&	mon11	==1	&	st36==1
replace unemp=	9.9		if	year==	2010	&	mon12	==1	&	st36==1


replace unemp=	4.2	if	year==	2007	&	mon1	==1	&	st37==1
replace unemp=	4.2	if	year==	2007	&	mon2	==1	&	st37==1
replace unemp=	4.1	if	year==	2007	&	mon3	==1	&	st37==1
replace unemp=	4.2	if	year==	2007	&	mon4	==1	&	st37==1
replace unemp=	4.2	if	year==	2007	&	mon5	==1	&	st37==1
replace unemp=	4.2	if	year==	2007	&	mon6	==1	&	st37==1
replace unemp=	4.2	if	year==	2007	&	mon7	==1	&	st37==1
replace unemp=	4.1	if	year==	2007	&	mon8	==1	&	st37==1
replace unemp=	4	if	year==	2007	&	mon9	==1	&	st37==1
replace unemp=	3.9	if	year==	2007	&	mon10	==1	&	st37==1
replace unemp=	3.7	if	year==	2007	&	mon11	==1	&	st37==1
replace unemp=	3.6	if	year==	2007	&	mon12	==1	&	st37==1
replace unemp=	3.4	if	year==	2008	&	mon1	==1	&	st37==1
replace unemp=	3.2	if	year==	2008	&	mon2	==1	&	st37==1
replace unemp=	3.2	if	year==	2008	&	mon3	==1	&	st37==1
replace unemp=	3.2	if	year==	2008	&	mon4	==1	&	st37==1
replace unemp=	3.5	if	year==	2008	&	mon5	==1	&	st37==1
replace unemp=	3.6	if	year==	2008	&	mon6	==1	&	st37==1
replace unemp=	3.7	if	year==	2008	&	mon7	==1	&	st37==1
replace unemp=	3.9	if	year==	2008	&	mon8	==1	&	st37==1
replace unemp=	3.9	if	year==	2008	&	mon9	==1	&	st37==1
replace unemp=	4.1	if	year==	2008	&	mon10	==1	&	st37==1
replace unemp=	4.3	if	year==	2008	&	mon11	==1	&	st37==1
replace unemp=	4.7	if	year==	2008	&	mon12	==1	&	st37==1
replace unemp=	5.1	if	year==	2009	&	mon1	==1	&	st37==1
replace unemp=	5.5	if	year==	2009	&	mon2	==1	&	st37==1
replace unemp=	5.9	if	year==	2009	&	mon3	==1	&	st37==1
replace unemp=	6.2	if	year==	2009	&	mon4	==1	&	st37==1
replace unemp=	6.6	if	year==	2009	&	mon5	==1	&	st37==1
replace unemp=	6.9	if	year==	2009	&	mon6	==1	&	st37==1
replace unemp=	7	if	year==	2009	&	mon7	==1	&	st37==1
replace unemp=	7.1	if	year==	2009	&	mon8	==1	&	st37==1
replace unemp=	7.2	if	year==	2009	&	mon9	==1	&	st37==1
replace unemp=	7.2	if	year==	2009	&	mon10	==1	&	st37==1
replace unemp=	7.2	if	year==	2009	&	mon11	==1	&	st37==1
replace unemp=	7.3	if	year==	2009	&	mon12	==1	&	st37==1

replace unemp=	7.3	if	year==	2010	&	mon1	==1	&	st37==1
replace unemp=	7.3	if	year==	2010	&	mon2	==1	&	st37==1
replace unemp=	7.3	if	year==	2010	&	mon3	==1	&	st37==1
replace unemp=	7.2	if	year==	2010	&	mon4	==1	&	st37==1
replace unemp=	7.1	if	year==	2010	&	mon5	==1	&	st37==1
replace unemp=	7	if	year==	2010	&	mon6	==1	&	st37==1
replace unemp=	7	if	year==	2010	&	mon7	==1	&	st37==1
replace unemp=	7	if	year==	2010	&	mon8	==1	&	st37==1
replace unemp=	6.9	if	year==	2010	&	mon9	==1	&	st37==1
replace unemp=	6.9	if	year==	2010	&	mon10	==1	&	st37==1
replace unemp=	6.9	if	year==	2010	&	mon11	==1	&	st37==1
replace unemp=	6.8	if	year==	2010	&	mon12	==1	&	st37==1


replace unemp=	5.1	if	year==	2007	&	mon1	==1	&	st38==1
replace unemp=	5	if	year==	2007	&	mon2	==1	&	st38==1
replace unemp=	5	if	year==	2007	&	mon3	==1	&	st38==1
replace unemp=	5	if	year==	2007	&	mon4	==1	&	st38==1
replace unemp=	5	if	year==	2007	&	mon5	==1	&	st38==1
replace unemp=	5.1	if	year==	2007	&	mon6	==1	&	st38==1
replace unemp=	5.2	if	year==	2007	&	mon7	==1	&	st38==1
replace unemp=	5.3	if	year==	2007	&	mon8	==1	&	st38==1
replace unemp=	5.3	if	year==	2007	&	mon9	==1	&	st38==1
replace unemp=	5.3	if	year==	2007	&	mon10	==1	&	st38==1
replace unemp=	5.3	if	year==	2007	&	mon11	==1	&	st38==1
replace unemp=	5.2	if	year==	2007	&	mon12	==1	&	st38==1
replace unemp=	5.2	if	year==	2008	&	mon1	==1	&	st38==1
replace unemp=	5.2	if	year==	2008	&	mon2	==1	&	st38==1
replace unemp=	5.3	if	year==	2008	&	mon3	==1	&	st38==1
replace unemp=	5.4	if	year==	2008	&	mon4	==1	&	st38==1
replace unemp=	5.7	if	year==	2008	&	mon5	==1	&	st38==1
replace unemp=	6	if	year==	2008	&	mon6	==1	&	st38==1
replace unemp=	6.3	if	year==	2008	&	mon7	==1	&	st38==1
replace unemp=	6.7	if	year==	2008	&	mon8	==1	&	st38==1
replace unemp=	7.2	if	year==	2008	&	mon9	==1	&	st38==1
replace unemp=	7.7	if	year==	2008	&	mon10	==1	&	st38==1
replace unemp=	8.4	if	year==	2008	&	mon11	==1	&	st38==1
replace unemp=	9.2		if	year==	2008	&	mon12	==1	&	st38==1
replace unemp=	9.9		if	year==	2009	&	mon1	==1	&	st38==1
replace unemp=	10.6	if	year==	2009	&	mon2	==1	&	st38==1
replace unemp=	11.2	if	year==	2009	&	mon3	==1	&	st38==1
replace unemp=	11.5	if	year==	2009	&	mon4	==1	&	st38==1
replace unemp=	11.6	if	year==	2009	&	mon5	==1	&	st38==1
replace unemp=	11.6	if	year==	2009	&	mon6	==1	&	st38==1
replace unemp=	11.5	if	year==	2009	&	mon7	==1	&	st38==1
replace unemp=	11.3	if	year==	2009	&	mon8	==1	&	st38==1
replace unemp=	11.1	if	year==	2009	&	mon9	==1	&	st38==1
replace unemp=	11		if	year==	2009	&	mon10	==1	&	st38==1
replace unemp=	11		if	year==	2009	&	mon11	==1	&	st38==1
replace unemp=	11		if	year==	2009	&	mon12	==1	&	st38==1

replace unemp=	11		if	year==	2010	&	mon1	==1	&	st38==1
replace unemp=	11.1	if	year==	2010	&	mon2	==1	&	st38==1
replace unemp=	11		if	year==	2010	&	mon3	==1	&	st38==1
replace unemp=	11		if	year==	2010	&	mon4	==1	&	st38==1
replace unemp=	10.9	if	year==	2010	&	mon5	==1	&	st38==1
replace unemp=	10.8	if	year==	2010	&	mon6	==1	&	st38==1
replace unemp=	10.7	if	year==	2010	&	mon7	==1	&	st38==1
replace unemp=	10.7	if	year==	2010	&	mon8	==1	&	st38==1
replace unemp=	10.7	if	year==	2010	&	mon9	==1	&	st38==1
replace unemp=	10.6		if	year==	2010	&	mon10	==1	&	st38==1
replace unemp=	10.6		if	year==	2010	&	mon11	==1	&	st38==1
replace unemp=	10.6		if	year==	2010	&	mon12	==1	&	st38==1


replace unemp=	4.2	if	year==	2007	&	mon1	==1	&	st39==1
replace unemp=	4.2	if	year==	2007	&	mon2	==1	&	st39==1
replace unemp=	4.2	if	year==	2007	&	mon3	==1	&	st39==1
replace unemp=	4.2	if	year==	2007	&	mon4	==1	&	st39==1
replace unemp=	4.2	if	year==	2007	&	mon5	==1	&	st39==1
replace unemp=	4.3	if	year==	2007	&	mon6	==1	&	st39==1
replace unemp=	4.3	if	year==	2007	&	mon7	==1	&	st39==1
replace unemp=	4.4	if	year==	2007	&	mon8	==1	&	st39==1
replace unemp=	4.4	if	year==	2007	&	mon9	==1	&	st39==1
replace unemp=	4.5	if	year==	2007	&	mon10	==1	&	st39==1
replace unemp=	4.6	if	year==	2007	&	mon11	==1	&	st39==1
replace unemp=	4.5	if	year==	2007	&	mon12	==1	&	st39==1
replace unemp=	4.6	if	year==	2008	&	mon1	==1	&	st39==1
replace unemp=	4.7	if	year==	2008	&	mon2	==1	&	st39==1
replace unemp=	4.8	if	year==	2008	&	mon3	==1	&	st39==1
replace unemp=	4.9	if	year==	2008	&	mon4	==1	&	st39==1
replace unemp=	5	if	year==	2008	&	mon5	==1	&	st39==1
replace unemp=	5.2	if	year==	2008	&	mon6	==1	&	st39==1
replace unemp=	5.3	if	year==	2008	&	mon7	==1	&	st39==1
replace unemp=	5.4	if	year==	2008	&	mon8	==1	&	st39==1
replace unemp=	5.6	if	year==	2008	&	mon9	==1	&	st39==1
replace unemp=	5.9	if	year==	2008	&	mon10	==1	&	st39==1
replace unemp=	6.2	if	year==	2008	&	mon11	==1	&	st39==1
replace unemp=	6.5	if	year==	2008	&	mon12	==1	&	st39==1
replace unemp=	6.8	if	year==	2009	&	mon1	==1	&	st39==1
replace unemp=	7.2	if	year==	2009	&	mon2	==1	&	st39==1
replace unemp=	7.5	if	year==	2009	&	mon3	==1	&	st39==1
replace unemp=	7.8	if	year==	2009	&	mon4	==1	&	st39==1
replace unemp=	8	if	year==	2009	&	mon5	==1	&	st39==1
replace unemp=	8.2	if	year==	2009	&	mon6	==1	&	st39==1
replace unemp=	8.3	if	year==	2009	&	mon7	==1	&	st39==1
replace unemp=	8.4	if	year==	2009	&	mon8	==1	&	st39==1
replace unemp=	8.5	if	year==	2009	&	mon9	==1	&	st39==1
replace unemp=	8.5	if	year==	2009	&	mon10	==1	&	st39==1
replace unemp=	8.6	if	year==	2009	&	mon11	==1	&	st39==1
replace unemp=	8.7	if	year==	2009	&	mon12	==1	&	st39==1

replace unemp=	8.8	if	year==	2010	&	mon1	==1	&	st39==1
replace unemp=	8.8	if	year==	2010	&	mon2	==1	&	st39==1
replace unemp=	8.8	if	year==	2010	&	mon3	==1	&	st39==1
replace unemp=	8.8	if	year==	2010	&	mon4	==1	&	st39==1
replace unemp=	8.7	if	year==	2010	&	mon5	==1	&	st39==1
replace unemp=	8.7	if	year==	2010	&	mon6	==1	&	st39==1
replace unemp=	8.6	if	year==	2010	&	mon7	==1	&	st39==1
replace unemp=	8.6	if	year==	2010	&	mon8	==1	&	st39==1
replace unemp=	8.5	if	year==	2010	&	mon9	==1	&	st39==1
replace unemp=	8.5	if	year==	2010	&	mon10	==1	&	st39==1
replace unemp=	8.5	if	year==	2010	&	mon11	==1	&	st39==1
replace unemp=	8.5	if	year==	2010	&	mon12	==1	&	st39==1


replace unemp=	4.9	if	year==	2007	&	mon1	==1	&	st40==1
replace unemp=	4.9	if	year==	2007	&	mon2	==1	&	st40==1
replace unemp=	4.9	if	year==	2007	&	mon3	==1	&	st40==1
replace unemp=	5	if	year==	2007	&	mon4	==1	&	st40==1
replace unemp=	5.1	if	year==	2007	&	mon5	==1	&	st40==1
replace unemp=	5.2	if	year==	2007	&	mon6	==1	&	st40==1
replace unemp=	5.3	if	year==	2007	&	mon7	==1	&	st40==1
replace unemp=	5.4	if	year==	2007	&	mon8	==1	&	st40==1
replace unemp=	5.5	if	year==	2007	&	mon9	==1	&	st40==1
replace unemp=	5.7	if	year==	2007	&	mon10	==1	&	st40==1
replace unemp=	5.9	if	year==	2007	&	mon11	==1	&	st40==1
replace unemp=	6	if	year==	2007	&	mon12	==1	&	st40==1
replace unemp=	6.2	if	year==	2008	&	mon1	==1	&	st40==1
replace unemp=	6.4	if	year==	2008	&	mon2	==1	&	st40==1
replace unemp=	6.6	if	year==	2008	&	mon3	==1	&	st40==1
replace unemp=	6.9	if	year==	2008	&	mon4	==1	&	st40==1
replace unemp=	7.2	if	year==	2008	&	mon5	==1	&	st40==1
replace unemp=	7.6	if	year==	2008	&	mon6	==1	&	st40==1
replace unemp=	7.9	if	year==	2008	&	mon7	==1	&	st40==1
replace unemp=	8.2	if	year==	2008	&	mon8	==1	&	st40==1
replace unemp=	8.4	if	year==	2008	&	mon9	==1	&	st40==1
replace unemp=	8.7	if	year==	2008	&	mon10	==1	&	st40==1
replace unemp=	9		if	year==	2008	&	mon11	==1	&	st40==1
replace unemp=	9.3		if	year==	2008	&	mon12	==1	&	st40==1
replace unemp=	9.6		if	year==	2009	&	mon1	==1	&	st40==1
replace unemp=	9.8		if	year==	2009	&	mon2	==1	&	st40==1
replace unemp=	10.1	if	year==	2009	&	mon3	==1	&	st40==1
replace unemp=	10.3	if	year==	2009	&	mon4	==1	&	st40==1
replace unemp=	10.5	if	year==	2009	&	mon5	==1	&	st40==1
replace unemp=	10.8	if	year==	2009	&	mon6	==1	&	st40==1
replace unemp=	11		if	year==	2009	&	mon7	==1	&	st40==1
replace unemp=	11.2	if	year==	2009	&	mon8	==1	&	st40==1
replace unemp=	11.4	if	year==	2009	&	mon9	==1	&	st40==1
replace unemp=	11.6	if	year==	2009	&	mon10	==1	&	st40==1
replace unemp=	11.7	if	year==	2009	&	mon11	==1	&	st40==1
replace unemp=	11.8	if	year==	2009	&	mon12	==1	&	st40==1

replace unemp=	11.8	if	year==	2010	&	mon1	==1	&	st40==1
replace unemp=  11.8	if	year==	2010	&	mon2	==1	&	st40==1
replace unemp=	11.8	if	year==	2010	&	mon3	==1	&	st40==1
replace unemp=	11.7	if	year==	2010	&	mon4	==1	&	st40==1
replace unemp=	11.7	if	year==	2010	&	mon5	==1	&	st40==1
replace unemp=	11.6	if	year==	2010	&	mon6	==1	&	st40==1
replace unemp=	11.6	if	year==	2010	&	mon7	==1	&	st40==1
replace unemp=	11.5	if	year==	2010	&	mon8	==1	&	st40==1
replace unemp=	11.5	if	year==	2010	&	mon9	==1	&	st40==1
replace unemp=	11.5	if	year==	2010	&	mon10	==1	&	st40==1
replace unemp=	11.5	if	year==	2010	&	mon11	==1	&	st40==1
replace unemp=	11.5	if	year==	2010	&	mon12	==1	&	st40==1


replace unemp=	5.9	if	year==	2007	&	mon1	==1	&	st41==1
replace unemp=	5.8	if	year==	2007	&	mon2	==1	&	st41==1
replace unemp=	5.6	if	year==	2007	&	mon3	==1	&	st41==1
replace unemp=	5.5	if	year==	2007	&	mon4	==1	&	st41==1
replace unemp=	5.5	if	year==	2007	&	mon5	==1	&	st41==1
replace unemp=	5.5	if	year==	2007	&	mon6	==1	&	st41==1
replace unemp=	5.5	if	year==	2007	&	mon7	==1	&	st41==1
replace unemp=	5.6	if	year==	2007	&	mon8	==1	&	st41==1
replace unemp=	5.6	if	year==	2007	&	mon9	==1	&	st41==1
replace unemp=	5.6	if	year==	2007	&	mon10	==1	&	st41==1
replace unemp=	5.6	if	year==	2007	&	mon11	==1	&	st41==1
replace unemp=	5.5	if	year==	2007	&	mon12	==1	&	st41==1
replace unemp=	5.5	if	year==	2008	&	mon1	==1	&	st41==1
replace unemp=	5.5	if	year==	2008	&	mon2	==1	&	st41==1
replace unemp=	5.6	if	year==	2008	&	mon3	==1	&	st41==1
replace unemp=	5.7	if	year==	2008	&	mon4	==1	&	st41==1
replace unemp=	6	if	year==	2008	&	mon5	==1	&	st41==1
replace unemp=	6.4	if	year==	2008	&	mon6	==1	&	st41==1
replace unemp=	6.7	if	year==	2008	&	mon7	==1	&	st41==1
replace unemp=	7.1	if	year==	2008	&	mon8	==1	&	st41==1
replace unemp=	7.5	if	year==	2008	&	mon9	==1	&	st41==1
replace unemp=	8	if	year==	2008	&	mon10	==1	&	st41==1
replace unemp=	8.6	if	year==	2008	&	mon11	==1	&	st41==1
replace unemp=	9.2	if	year==	2008	&	mon12	==1	&	st41==1
replace unemp=	9.9	if	year==	2009	&	mon1	==1	&	st41==1
replace unemp=	10.5	if	year==	2009	&	mon2	==1	&	st41==1
replace unemp=	10.9	if	year==	2009	&	mon3	==1	&	st41==1
replace unemp=	11.3	if	year==	2009	&	mon4	==1	&	st41==1
replace unemp=	11.5	if	year==	2009	&	mon5	==1	&	st41==1
replace unemp=	11.6	if	year==	2009	&	mon6	==1	&	st41==1
replace unemp=	11.7	if	year==	2009	&	mon7	==1	&	st41==1
replace unemp=	11.7	if	year==	2009	&	mon8	==1	&	st41==1
replace unemp=	11.7	if	year==	2009	&	mon9	==1	&	st41==1
replace unemp=	11.7	if	year==	2009	&	mon10	==1	&	st41==1
replace unemp=	11.8	if	year==	2009	&	mon11	==1	&	st41==1
replace unemp=	11.8	if	year==	2009	&	mon12	==1	&	st41==1

replace unemp=	11.7	if	year==	2010	&	mon1	==1	&	st41==1
replace unemp=	11.6	if	year==	2010	&	mon2	==1	&	st41==1
replace unemp=	11.5	if	year==	2010	&	mon3	==1	&	st41==1
replace unemp=	11.3	if	year==	2010	&	mon4	==1	&	st41==1
replace unemp=	11.2	if	year==	2010	&	mon5	==1	&	st41==1
replace unemp=	11		if	year==	2010	&	mon6	==1	&	st41==1
replace unemp=	11		if	year==	2010	&	mon7	==1	&	st41==1
replace unemp=	11		if	year==	2010	&	mon8	==1	&	st41==1
replace unemp=	10.9	if	year==	2010	&	mon9	==1	&	st41==1
replace unemp=	10.9	if	year==	2010	&	mon10	==1	&	st41==1
replace unemp=	10.9	if	year==	2010	&	mon11	==1	&	st41==1
replace unemp=	10.9	if	year==	2010	&	mon12	==1	&	st41==1


replace unemp=	3	if	year==	2007	&	mon1	==1	&	st42==1
replace unemp=	3	if	year==	2007	&	mon2	==1	&	st42==1
replace unemp=	2.9	if	year==	2007	&	mon3	==1	&	st42==1
replace unemp=	2.9	if	year==	2007	&	mon4	==1	&	st42==1
replace unemp=	2.9	if	year==	2007	&	mon5	==1	&	st42==1
replace unemp=	2.9	if	year==	2007	&	mon6	==1	&	st42==1
replace unemp=	3	if	year==	2007	&	mon7	==1	&	st42==1
replace unemp=	3	if	year==	2007	&	mon8	==1	&	st42==1
replace unemp=	2.9	if	year==	2007	&	mon9	==1	&	st42==1
replace unemp=	2.9	if	year==	2007	&	mon10	==1	&	st42==1
replace unemp=	2.9	if	year==	2007	&	mon11	==1	&	st42==1
replace unemp=	2.8	if	year==	2007	&	mon12	==1	&	st42==1
replace unemp=	2.7	if	year==	2008	&	mon1	==1	&	st42==1
replace unemp=	2.7	if	year==	2008	&	mon2	==1	&	st42==1
replace unemp=	2.7	if	year==	2008	&	mon3	==1	&	st42==1
replace unemp=	2.8	if	year==	2008	&	mon4	==1	&	st42==1
replace unemp=	2.9	if	year==	2008	&	mon5	==1	&	st42==1
replace unemp=	3	if	year==	2008	&	mon6	==1	&	st42==1
replace unemp=	3.2	if	year==	2008	&	mon7	==1	&	st42==1
replace unemp=	3.3	if	year==	2008	&	mon8	==1	&	st42==1
replace unemp=	3.4	if	year==	2008	&	mon9	==1	&	st42==1
replace unemp=	3.5	if	year==	2008	&	mon10	==1	&	st42==1
replace unemp=	3.7	if	year==	2008	&	mon11	==1	&	st42==1
replace unemp=	4	if	year==	2008	&	mon12	==1	&	st42==1
replace unemp=	4.3	if	year==	2009	&	mon1	==1	&	st42==1
replace unemp=	4.6	if	year==	2009	&	mon2	==1	&	st42==1
replace unemp=	4.9	if	year==	2009	&	mon3	==1	&	st42==1
replace unemp=	5	if	year==	2009	&	mon4	==1	&	st42==1
replace unemp=	5.1	if	year==	2009	&	mon5	==1	&	st42==1
replace unemp=	5.1	if	year==	2009	&	mon6	==1	&	st42==1
replace unemp=	5	if	year==	2009	&	mon7	==1	&	st42==1
replace unemp=	5	if	year==	2009	&	mon8	==1	&	st42==1
replace unemp=	5	if	year==	2009	&	mon9	==1	&	st42==1
replace unemp=	5	if	year==	2009	&	mon10	==1	&	st42==1
replace unemp=	5.1	if	year==	2009	&	mon11	==1	&	st42==1
replace unemp=	5.2	if	year==	2009	&	mon12	==1	&	st42==1


replace unemp=	5.2	if	year==	2010	&	mon1	==1	&	st42==1
replace unemp=	5.2	if	year==	2010	&	mon2	==1	&	st42==1
replace unemp=	5.1	if	year==	2010	&	mon3	==1	&	st42==1
replace unemp=	5	if	year==	2010	&	mon4	==1	&	st42==1
replace unemp=	4.8	if	year==	2010	&	mon5	==1	&	st42==1
replace unemp=	4.7	if	year==	2010	&	mon6	==1	&	st42==1
replace unemp=	4.7	if	year==	2010	&	mon7	==1	&	st42==1
replace unemp=	4.6	if	year==	2010	&	mon8	==1	&	st42==1
replace unemp=	4.6	if	year==	2010	&	mon9	==1	&	st42==1
replace unemp=	4.6	if	year==	2010	&	mon10	==1	&	st42==1
replace unemp=	4.7	if	year==	2010	&	mon11	==1	&	st42==1
replace unemp=	4.7	if	year==	2010	&	mon12	==1	&	st42==1



replace unemp=	4.7	if	year==	2007	&	mon1	==1	&	st43==1
replace unemp=	4.6	if	year==	2007	&	mon2	==1	&	st43==1
replace unemp=	4.6	if	year==	2007	&	mon3	==1	&	st43==1
replace unemp=	4.5	if	year==	2007	&	mon4	==1	&	st43==1
replace unemp=	4.5	if	year==	2007	&	mon5	==1	&	st43==1
replace unemp=	4.6	if	year==	2007	&	mon6	==1	&	st43==1
replace unemp=	4.7	if	year==	2007	&	mon7	==1	&	st43==1
replace unemp=	4.9	if	year==	2007	&	mon8	==1	&	st43==1
replace unemp=	5.1	if	year==	2007	&	mon9	==1	&	st43==1
replace unemp=	5.2	if	year==	2007	&	mon10	==1	&	st43==1
replace unemp=	5.4	if	year==	2007	&	mon11	==1	&	st43==1
replace unemp=	5.4	if	year==	2007	&	mon12	==1	&	st43==1
replace unemp=	5.5	if	year==	2008	&	mon1	==1	&	st43==1
replace unemp=	5.6	if	year==	2008	&	mon2	==1	&	st43==1
replace unemp=	5.7	if	year==	2008	&	mon3	==1	&	st43==1
replace unemp=	5.9	if	year==	2008	&	mon4	==1	&	st43==1
replace unemp=	6.2	if	year==	2008	&	mon5	==1	&	st43==1
replace unemp=	6.5	if	year==	2008	&	mon6	==1	&	st43==1
replace unemp=	6.7	if	year==	2008	&	mon7	==1	&	st43==1
replace unemp=	6.9	if	year==	2008	&	mon8	==1	&	st43==1
replace unemp=	7.1	if	year==	2008	&	mon9	==1	&	st43==1
replace unemp=	7.4	if	year==	2008	&	mon10	==1	&	st43==1
replace unemp=	7.8	if	year==	2008	&	mon11	==1	&	st43==1
replace unemp=	8.4	if	year==	2008	&	mon12	==1	&	st43==1
replace unemp=	9	if	year==	2009	&	mon1	==1	&	st43==1
replace unemp=	9.6	if	year==	2009	&	mon2	==1	&	st43==1
replace unemp=	10.1	if	year==	2009	&	mon3	==1	&	st43==1
replace unemp=	10.5	if	year==	2009	&	mon4	==1	&	st43==1
replace unemp=	10.7	if	year==	2009	&	mon5	==1	&	st43==1
replace unemp=	10.8	if	year==	2009	&	mon6	==1	&	st43==1
replace unemp=	10.8	if	year==	2009	&	mon7	==1	&	st43==1
replace unemp=	10.8	if	year==	2009	&	mon8	==1	&	st43==1
replace unemp=	10.7	if	year==	2009	&	mon9	==1	&	st43==1
replace unemp=	10.6	if	year==	2009	&	mon10	==1	&	st43==1
replace unemp=	10.5	if	year==	2009	&	mon11	==1	&	st43==1
replace unemp=	10.5	if	year==	2009	&	mon12	==1	&	st43==1


replace unemp=	10.4	if	year==	2010	&	mon1	==1	&	st43==1
replace unemp=	10.3	if	year==	2010	&	mon2	==1	&	st43==1
replace unemp=	10.2	if	year==	2010	&	mon3	==1	&	st43==1
replace unemp=	10		if	year==	2010	&	mon4	==1	&	st43==1
replace unemp=	9.8		if	year==	2010	&	mon5	==1	&	st43==1
replace unemp=	9.6		if	year==	2010	&	mon6	==1	&	st43==1
replace unemp=	9.5		if	year==	2010	&	mon7	==1	&	st43==1
replace unemp=	9.4		if	year==	2010	&	mon8	==1	&	st43==1
replace unemp=	9.4		if	year==	2010	&	mon9	==1	&	st43==1
replace unemp=	9.4		if	year==	2010	&	mon10	==1	&	st43==1
replace unemp=	9.4	 	if	year==	2010	&	mon11	==1	&	st43==1
replace unemp=	9.4 	if	year==	2010	&	mon12	==1	&	st43==1


replace unemp=	4.5	if	year==	2007	&	mon1	==1	&	st44==1
replace unemp=	4.4	if	year==	2007	&	mon2	==1	&	st44==1
replace unemp=	4.3	if	year==	2007	&	mon3	==1	&	st44==1
replace unemp=	4.3	if	year==	2007	&	mon4	==1	&	st44==1
replace unemp=	4.3	if	year==	2007	&	mon5	==1	&	st44==1
replace unemp=	4.3	if	year==	2007	&	mon6	==1	&	st44==1
replace unemp=	4.4	if	year==	2007	&	mon7	==1	&	st44==1
replace unemp=	4.4	if	year==	2007	&	mon8	==1	&	st44==1
replace unemp=	4.4	if	year==	2007	&	mon9	==1	&	st44==1
replace unemp=	4.4	if	year==	2007	&	mon10	==1	&	st44==1
replace unemp=	4.4	if	year==	2007	&	mon11	==1	&	st44==1
replace unemp=	4.4	if	year==	2007	&	mon12	==1	&	st44==1
replace unemp=	4.4	if	year==	2008	&	mon1	==1	&	st44==1
replace unemp=	4.4	if	year==	2008	&	mon2	==1	&	st44==1
replace unemp=	4.4	if	year==	2008	&	mon3	==1	&	st44==1
replace unemp=	4.5	if	year==	2008	&	mon4	==1	&	st44==1
replace unemp=	4.6	if	year==	2008	&	mon5	==1	&	st44==1
replace unemp=	4.8	if	year==	2008	&	mon6	==1	&	st44==1
replace unemp=	4.9	if	year==	2008	&	mon7	==1	&	st44==1
replace unemp=	5.1	if	year==	2008	&	mon8	==1	&	st44==1
replace unemp=	5.2	if	year==	2008	&	mon9	==1	&	st44==1
replace unemp=	5.4	if	year==	2008	&	mon10	==1	&	st44==1
replace unemp=	5.7	if	year==	2008	&	mon11	==1	&	st44==1
replace unemp=	6.1	if	year==	2008	&	mon12	==1	&	st44==1
replace unemp=	6.4	if	year==	2009	&	mon1	==1	&	st44==1
replace unemp=	6.7	if	year==	2009	&	mon2	==1	&	st44==1
replace unemp=	7	if	year==	2009	&	mon3	==1	&	st44==1
replace unemp=	7.2	if	year==	2009	&	mon4	==1	&	st44==1
replace unemp=	7.5	if	year==	2009	&	mon5	==1	&	st44==1
replace unemp=	7.7	if	year==	2009	&	mon6	==1	&	st44==1
replace unemp=	7.8	if	year==	2009	&	mon7	==1	&	st44==1
replace unemp=	7.9	if	year==	2009	&	mon8	==1	&	st44==1
replace unemp=	8	if	year==	2009	&	mon9	==1	&	st44==1
replace unemp=	8.1	if	year==	2009	&	mon10	==1	&	st44==1
replace unemp=	8.1	if	year==	2009	&	mon11	==1	&	st44==1
replace unemp=	8.1	if	year==	2009	&	mon12	==1	&	st44==1

replace unemp=	8.2	if	year==	2010	&	mon1	==1	&	st44==1
replace unemp=	8.2	if	year==	2010	&	mon2	==1	&	st44==1
replace unemp=	8.2	if	year==	2010	&	mon3	==1	&	st44==1
replace unemp=	8.2	if	year==	2010	&	mon4	==1	&	st44==1
replace unemp=	8.1	if	year==	2010	&	mon5	==1	&	st44==1
replace unemp=	8.1	if	year==	2010	&	mon6	==1	&	st44==1
replace unemp=	8.1	if	year==	2010	&	mon7	==1	&	st44==1
replace unemp=	8.2	if	year==	2010	&	mon8	==1	&	st44==1
replace unemp=	8.2	if	year==	2010	&	mon9	==1	&	st44==1
replace unemp=	8.2	if	year==	2010	&	mon10	==1	&	st44==1
replace unemp=	8.3	if	year==	2010	&	mon11	==1	&	st44==1
replace unemp=	8.3	if	year==	2010	&	mon12	==1	&	st44==1


replace unemp=	2.4	if	year==	2007	&	mon1	==1	&	st45==1
replace unemp=	2.4	if	year==	2007	&	mon2	==1	&	st45==1
replace unemp=	2.4	if	year==	2007	&	mon3	==1	&	st45==1
replace unemp=	2.4	if	year==	2007	&	mon4	==1	&	st45==1
replace unemp=	2.5	if	year==	2007	&	mon5	==1	&	st45==1
replace unemp=	2.6	if	year==	2007	&	mon6	==1	&	st45==1
replace unemp=	2.7	if	year==	2007	&	mon7	==1	&	st45==1
replace unemp=	2.8	if	year==	2007	&	mon8	==1	&	st45==1
replace unemp=	2.8	if	year==	2007	&	mon9	==1	&	st45==1
replace unemp=	2.9	if	year==	2007	&	mon10	==1	&	st45==1
replace unemp=	2.9	if	year==	2007	&	mon11	==1	&	st45==1
replace unemp=	3	if	year==	2007	&	mon12	==1	&	st45==1
replace unemp=	3	if	year==	2008	&	mon1	==1	&	st45==1
replace unemp=	3.1	if	year==	2008	&	mon2	==1	&	st45==1
replace unemp=	3.2	if	year==	2008	&	mon3	==1	&	st45==1
replace unemp=	3.3	if	year==	2008	&	mon4	==1	&	st45==1
replace unemp=	3.4	if	year==	2008	&	mon5	==1	&	st45==1
replace unemp=	3.5	if	year==	2008	&	mon6	==1	&	st45==1
replace unemp=	3.6	if	year==	2008	&	mon7	==1	&	st45==1
replace unemp=	3.8	if	year==	2008	&	mon8	==1	&	st45==1
replace unemp=	4	if	year==	2008	&	mon9	==1	&	st45==1
replace unemp=	4.3	if	year==	2008	&	mon10	==1	&	st45==1
replace unemp=	4.8	if	year==	2008	&	mon11	==1	&	st45==1
replace unemp=	5.3	if	year==	2008	&	mon12	==1	&	st45==1
replace unemp=	5.8	if	year==	2009	&	mon1	==1	&	st45==1
replace unemp=	6.3	if	year==	2009	&	mon2	==1	&	st45==1
replace unemp=	6.6	if	year==	2009	&	mon3	==1	&	st45==1
replace unemp=	6.9	if	year==	2009	&	mon4	==1	&	st45==1
replace unemp=	7.1	if	year==	2009	&	mon5	==1	&	st45==1
replace unemp=	7.2	if	year==	2009	&	mon6	==1	&	st45==1
replace unemp=	7.3	if	year==	2009	&	mon7	==1	&	st45==1
replace unemp=	7.4	if	year==	2009	&	mon8	==1	&	st45==1
replace unemp=	7.4	if	year==	2009	&	mon9	==1	&	st45==1
replace unemp=	7.5	if	year==	2009	&	mon10	==1	&	st45==1
replace unemp=	7.7	if	year==	2009	&	mon11	==1	&	st45==1
replace unemp=	7.8	if	year==	2009	&	mon12	==1	&	st45==1


replace unemp=	8	if	year==	2010	&	mon1	==1	&	st45==1
replace unemp=	8	if	year==	2010	&	mon2	==1	&	st45==1
replace unemp=	8	if	year==	2010	&	mon3	==1	&	st45==1
replace unemp=	7.9	if	year==	2010	&	mon4	==1	&	st45==1
replace unemp=	7.8	if	year==	2010	&	mon5	==1	&	st45==1
replace unemp=	7.7	if	year==	2010	&	mon6	==1	&	st45==1
replace unemp=	7.6	if	year==	2010	&	mon7	==1	&	st45==1
replace unemp=	7.6	if	year==	2010	&	mon8	==1	&	st45==1
replace unemp=	7.6	if	year==	2010	&	mon9	==1	&	st45==1
replace unemp=	7.6	if	year==	2010	&	mon10	==1	&	st45==1
replace unemp=	7.5	if	year==	2010	&	mon11	==1	&	st45==1
replace unemp=	7.5	if	year==	2010	&	mon12	==1	&	st45==1



replace unemp=	3.9	if	year==	2007	&	mon1	==1	&	st46==1
replace unemp=	3.9	if	year==	2007	&	mon2	==1	&	st46==1
replace unemp=	3.9	if	year==	2007	&	mon3	==1	&	st46==1
replace unemp=	3.9	if	year==	2007	&	mon4	==1	&	st46==1
replace unemp=	3.9	if	year==	2007	&	mon5	==1	&	st46==1
replace unemp=	3.9	if	year==	2007	&	mon6	==1	&	st46==1
replace unemp=	3.9	if	year==	2007	&	mon7	==1	&	st46==1
replace unemp=	3.9	if	year==	2007	&	mon8	==1	&	st46==1
replace unemp=	4	if	year==	2007	&	mon9	==1	&	st46==1
replace unemp=	4	if	year==	2007	&	mon10	==1	&	st46==1
replace unemp=	4	if	year==	2007	&	mon11	==1	&	st46==1
replace unemp=	4.1	if	year==	2007	&	mon12	==1	&	st46==1
replace unemp=	4.1	if	year==	2008	&	mon1	==1	&	st46==1
replace unemp=	4.1	if	year==	2008	&	mon2	==1	&	st46==1
replace unemp=	4.2	if	year==	2008	&	mon3	==1	&	st46==1
replace unemp=	4.2	if	year==	2008	&	mon4	==1	&	st46==1
replace unemp=	4.3	if	year==	2008	&	mon5	==1	&	st46==1
replace unemp=	4.3	if	year==	2008	&	mon6	==1	&	st46==1
replace unemp=	4.4	if	year==	2008	&	mon7	==1	&	st46==1
replace unemp=	4.5	if	year==	2008	&	mon8	==1	&	st46==1
replace unemp=	4.6	if	year==	2008	&	mon9	==1	&	st46==1
replace unemp=	4.9	if	year==	2008	&	mon10	==1	&	st46==1
replace unemp=	5.2	if	year==	2008	&	mon11	==1	&	st46==1
replace unemp=	5.7	if	year==	2008	&	mon12	==1	&	st46==1
replace unemp=	6.2	if	year==	2009	&	mon1	==1	&	st46==1
replace unemp=	6.7	if	year==	2009	&	mon2	==1	&	st46==1
replace unemp=	7.1	if	year==	2009	&	mon3	==1	&	st46==1
replace unemp=	7.3	if	year==	2009	&	mon4	==1	&	st46==1
replace unemp=	7.3	if	year==	2009	&	mon5	==1	&	st46==1
replace unemp=	7.2	if	year==	2009	&	mon6	==1	&	st46==1
replace unemp=	7.1	if	year==	2009	&	mon7	==1	&	st46==1
replace unemp=	6.9	if	year==	2009	&	mon8	==1	&	st46==1
replace unemp=	6.8	if	year==	2009	&	mon9	==1	&	st46==1
replace unemp=	6.7	if	year==	2009	&	mon10	==1	&	st46==1
replace unemp=	6.7	if	year==	2009	&	mon11	==1	&	st46==1
replace unemp=	6.7	if	year==	2009	&	mon12	==1	&	st46==1

replace unemp=	6.7	if	year==	2010	&	mon1	==1	&	st46==1
replace unemp=	6.7	if	year==	2010	&	mon2	==1	&	st46==1
replace unemp=	6.6	if	year==	2010	&	mon3	==1	&	st46==1
replace unemp=	6.5	if	year==	2010	&	mon4	==1	&	st46==1
replace unemp=	6.3	if	year==	2010	&	mon5	==1	&	st46==1
replace unemp=	6.2	if	year==	2010	&	mon6	==1	&	st46==1
replace unemp=	6.1	if	year==	2010	&	mon7	==1	&	st46==1
replace unemp=	6	if	year==	2010	&	mon8	==1	&	st46==1
replace unemp=	5.9 if	year==	2010	&	mon9	==1	&	st46==1
replace unemp=	5.9	if	year==	2010	&	mon10	==1	&	st46==1
replace unemp=	5.8	if	year==	2010	&	mon11	==1	&	st46==1
replace unemp=	5.8	if	year==	2010	&	mon12	==1	&	st46==1


replace unemp=	2.9	if	year==	2007	&	mon1	==1	&	st47==1
replace unemp=	2.9	if	year==	2007	&	mon2	==1	&	st47==1
replace unemp=	2.8	if	year==	2007	&	mon3	==1	&	st47==1
replace unemp=	2.9	if	year==	2007	&	mon4	==1	&	st47==1
replace unemp=	2.9	if	year==	2007	&	mon5	==1	&	st47==1
replace unemp=	3	if	year==	2007	&	mon6	==1	&	st47==1
replace unemp=	3	if	year==	2007	&	mon7	==1	&	st47==1
replace unemp=	3.1	if	year==	2007	&	mon8	==1	&	st47==1
replace unemp=	3.2	if	year==	2007	&	mon9	==1	&	st47==1
replace unemp=	3.2	if	year==	2007	&	mon10	==1	&	st47==1
replace unemp=	3.2	if	year==	2007	&	mon11	==1	&	st47==1
replace unemp=	3.3	if	year==	2007	&	mon12	==1	&	st47==1
replace unemp=	3.3	if	year==	2008	&	mon1	==1	&	st47==1
replace unemp=	3.3	if	year==	2008	&	mon2	==1	&	st47==1
replace unemp=	3.4	if	year==	2008	&	mon3	==1	&	st47==1
replace unemp=	3.5	if	year==	2008	&	mon4	==1	&	st47==1
replace unemp=	3.7	if	year==	2008	&	mon5	==1	&	st47==1
replace unemp=	3.8	if	year==	2008	&	mon6	==1	&	st47==1
replace unemp=	4	if	year==	2008	&	mon7	==1	&	st47==1
replace unemp=	4.1	if	year==	2008	&	mon8	==1	&	st47==1
replace unemp=	4.3	if	year==	2008	&	mon9	==1	&	st47==1
replace unemp=	4.5	if	year==	2008	&	mon10	==1	&	st47==1
replace unemp=	4.8	if	year==	2008	&	mon11	==1	&	st47==1
replace unemp=	5.3	if	year==	2008	&	mon12	==1	&	st47==1
replace unemp=	5.7	if	year==	2009	&	mon1	==1	&	st47==1
replace unemp=	6.1	if	year==	2009	&	mon2	==1	&	st47==1
replace unemp=	6.5	if	year==	2009	&	mon3	==1	&	st47==1
replace unemp=	6.8	if	year==	2009	&	mon4	==1	&	st47==1
replace unemp=	6.9	if	year==	2009	&	mon5	==1	&	st47==1
replace unemp=	7	if	year==	2009	&	mon6	==1	&	st47==1
replace unemp=	7	if	year==	2009	&	mon7	==1	&	st47==1
replace unemp=	7.1	if	year==	2009	&	mon8	==1	&	st47==1
replace unemp=	7.1	if	year==	2009	&	mon9	==1	&	st47==1
replace unemp=	7.1	if	year==	2009	&	mon10	==1	&	st47==1
replace unemp=	7.1	if	year==	2009	&	mon11	==1	&	st47==1
replace unemp=	7.2	if	year==	2009	&	mon12	==1	&	st47==1


replace unemp=	7.2	if	year==	2010	&	mon1	==1	&	st47==1
replace unemp=	7.2	if	year==	2010	&	mon2	==1	&	st47==1
replace unemp=	7.1	if	year==	2010	&	mon3	==1	&	st47==1
replace unemp=	7.1	if	year==	2010	&	mon4	==1	&	st47==1
replace unemp=	7	if	year==	2010	&	mon5	==1	&	st47==1
replace unemp=	6.9	if	year==	2010	&	mon6	==1	&	st47==1
replace unemp=	6.8	if	year==	2010	&	mon7	==1	&	st47==1
replace unemp=	6.8	if	year==	2010	&	mon8	==1	&	st47==1
replace unemp=	6.7	if	year==	2010	&	mon9	==1	&	st47==1
replace unemp=	6.7	if	year==	2010	&	mon10	==1	&	st47==1
replace unemp=	6.6	if	year==	2010	&	mon11	==1	&	st47==1
replace unemp=	6.6	if	year==	2010	&	mon12	==1	&	st47==1


replace unemp=	5.2	if	year==	2007	&	mon1	==1	&	st48==1
replace unemp=	5.1	if	year==	2007	&	mon2	==1	&	st48==1
replace unemp=	5	if	year==	2007	&	mon3	==1	&	st48==1
replace unemp=	4.9	if	year==	2007	&	mon4	==1	&	st48==1
replace unemp=	4.9	if	year==	2007	&	mon5	==1	&	st48==1
replace unemp=	4.9	if	year==	2007	&	mon6	==1	&	st48==1
replace unemp=	4.9	if	year==	2007	&	mon7	==1	&	st48==1
replace unemp=	5	if	year==	2007	&	mon8	==1	&	st48==1
replace unemp=	5.1	if	year==	2007	&	mon9	==1	&	st48==1
replace unemp=	5.1	if	year==	2007	&	mon10	==1	&	st48==1
replace unemp=	5.2	if	year==	2007	&	mon11	==1	&	st48==1
replace unemp=	5.2	if	year==	2007	&	mon12	==1	&	st48==1
replace unemp=	5.3	if	year==	2008	&	mon1	==1	&	st48==1
replace unemp=	5.3	if	year==	2008	&	mon2	==1	&	st48==1
replace unemp=	5.3	if	year==	2008	&	mon3	==1	&	st48==1
replace unemp=	5.4	if	year==	2008	&	mon4	==1	&	st48==1
replace unemp=	5.6	if	year==	2008	&	mon5	==1	&	st48==1
replace unemp=	5.7	if	year==	2008	&	mon6	==1	&	st48==1
replace unemp=	5.8	if	year==	2008	&	mon7	==1	&	st48==1
replace unemp=	6	if	year==	2008	&	mon8	==1	&	st48==1
replace unemp=	6.2	if	year==	2008	&	mon9	==1	&	st48==1
replace unemp=	6.5	if	year==	2008	&	mon10	==1	&	st48==1
replace unemp=	6.9	if	year==	2008	&	mon11	==1	&	st48==1
replace unemp=	7.4	if	year==	2008	&	mon12	==1	&	st48==1
replace unemp=	8	if	year==	2009	&	mon1	==1	&	st48==1
replace unemp=	8.6	if	year==	2009	&	mon2	==1	&	st48==1
replace unemp=	9.1	if	year==	2009	&	mon3	==1	&	st48==1
replace unemp=	9.4	if	year==	2009	&	mon4	==1	&	st48==1
replace unemp=	9.7	if	year==	2009	&	mon5	==1	&	st48==1
replace unemp=	9.8	if	year==	2009	&	mon6	==1	&	st48==1
replace unemp=	9.9	if	year==	2009	&	mon7	==1	&	st48==1
replace unemp=	10	if	year==	2009	&	mon8	==1	&	st48==1
replace unemp=	10.1	if	year==	2009	&	mon9	==1	&	st48==1
replace unemp=	10.3	if	year==	2009	&	mon10	==1	&	st48==1
replace unemp=	10.3	if	year==	2009	&	mon11	==1	&	st48==1
replace unemp=	10.4	if	year==	2009	&	mon12	==1	&	st48==1

replace unemp=	10.4	if	year==	2010	&	mon1	==1	&	st48==1
replace unemp=	10.3	if	year==	2010	&	mon2	==1	&	st48==1
replace unemp=	10.2	if	year==	2010	&	mon3	==1	&	st48==1
replace unemp=	10.1	if	year==	2010	&	mon4	==1	&	st48==1
replace unemp=	9.9		if	year==	2010	&	mon5	==1	&	st48==1
replace unemp=	9.8		if	year==	2010	&	mon6	==1	&	st48==1
replace unemp=	9.8		if	year==	2010	&	mon7	==1	&	st48==1
replace unemp=	9.7		if	year==	2010	&	mon8	==1	&	st48==1
replace unemp=	9.7		if	year==	2010	&	mon9	==1	&	st48==1
replace unemp=	9.8		if	year==	2010	&	mon10	==1	&	st48==1
replace unemp=	9.8		if	year==	2010	&	mon11	==1	&	st48==1
replace unemp=	9.7		if	year==	2010	&	mon12	==1	&	st48==1



replace unemp=	4.2	if	year==	2007	&	mon1	==1	&	st49==1
replace unemp=	4.1	if	year==	2007	&	mon2	==1	&	st49==1
replace unemp=	4.1	if	year==	2007	&	mon3	==1	&	st49==1
replace unemp=	4.1	if	year==	2007	&	mon4	==1	&	st49==1
replace unemp=	4.1	if	year==	2007	&	mon5	==1	&	st49==1
replace unemp=	4.2	if	year==	2007	&	mon6	==1	&	st49==1
replace unemp=	4.2	if	year==	2007	&	mon7	==1	&	st49==1
replace unemp=	4.3	if	year==	2007	&	mon8	==1	&	st49==1
replace unemp=	4.3	if	year==	2007	&	mon9	==1	&	st49==1
replace unemp=	4.2	if	year==	2007	&	mon10	==1	&	st49==1
replace unemp=	4.2	if	year==	2007	&	mon11	==1	&	st49==1
replace unemp=	4.1	if	year==	2007	&	mon12	==1	&	st49==1
replace unemp=	4	if	year==	2008	&	mon1	==1	&	st49==1
replace unemp=	3.9	if	year==	2008	&	mon2	==1	&	st49==1
replace unemp=	3.9	if	year==	2008	&	mon3	==1	&	st49==1
replace unemp=	3.9	if	year==	2008	&	mon4	==1	&	st49==1
replace unemp=	4	if	year==	2008	&	mon5	==1	&	st49==1
replace unemp=	4.1	if	year==	2008	&	mon6	==1	&	st49==1
replace unemp=	4.1	if	year==	2008	&	mon7	==1	&	st49==1
replace unemp=	4.2	if	year==	2008	&	mon8	==1	&	st49==1
replace unemp=	4.4	if	year==	2008	&	mon9	==1	&	st49==1
replace unemp=	4.6	if	year==	2008	&	mon10	==1	&	st49==1
replace unemp=	4.8	if	year==	2008	&	mon11	==1	&	st49==1
replace unemp=	5.2	if	year==	2008	&	mon12	==1	&	st49==1
replace unemp=	5.7	if	year==	2009	&	mon1	==1	&	st49==1
replace unemp=	6.3	if	year==	2009	&	mon2	==1	&	st49==1
replace unemp=	6.8	if	year==	2009	&	mon3	==1	&	st49==1
replace unemp=	7.3	if	year==	2009	&	mon4	==1	&	st49==1
replace unemp=	7.7	if	year==	2009	&	mon5	==1	&	st49==1
replace unemp=	8.1	if	year==	2009	&	mon6	==1	&	st49==1
replace unemp=	8.3	if	year==	2009	&	mon7	==1	&	st49==1
replace unemp=	8.4	if	year==	2009	&	mon8	==1	&	st49==1
replace unemp=	8.5	if	year==	2009	&	mon9	==1	&	st49==1
replace unemp=	8.5	if	year==	2009	&	mon10	==1	&	st49==1
replace unemp=	8.6	if	year==	2009	&	mon11	==1	&	st49==1
replace unemp=	8.7	if	year==	2009	&	mon12	==1	&	st49==1

replace unemp=	8.7	if	year==	2010	&	mon1	==1	&	st49==1
replace unemp=	8.8	if	year==	2010	&	mon2	==1	&	st49==1
replace unemp=	8.8	if	year==	2010	&	mon3	==1	&	st49==1
replace unemp=	8.8	if	year==	2010	&	mon4	==1	&	st49==1
replace unemp=	8.8	if	year==	2010	&	mon5	==1	&	st49==1
replace unemp=	8.9	if	year==	2010	&	mon6	==1	&	st49==1
replace unemp=	9	if	year==  2010    &	mon7	==1	&	st49==1
replace unemp=	9.2	if	year==	2010	&	mon8	==1	&	st49==1
replace unemp=	9.3	if	year==	2010	&	mon9	==1	&	st49==1
replace unemp=	9.5	if	year==	2010	&	mon10	==1	&	st49==1
replace unemp=	9.6	if	year==	2010	&	mon11	==1	&	st49==1
replace unemp=	9.7	if	year==	2010	&	mon12	==1	&	st49==1



replace unemp=	4.8	if	year==	2007	&	mon1	==1	&	st50==1
replace unemp=	4.8	if	year==	2007	&	mon2	==1	&	st50==1
replace unemp=	4.8	if	year==	2007	&	mon3	==1	&	st50==1
replace unemp=	4.8	if	year==	2007	&	mon4	==1	&	st50==1
replace unemp=	4.9	if	year==	2007	&	mon5	==1	&	st50==1
replace unemp=	4.9	if	year==	2007	&	mon6	==1	&	st50==1
replace unemp=	4.9	if	year==	2007	&	mon7	==1	&	st50==1
replace unemp=	4.8	if	year==	2007	&	mon8	==1	&	st50==1
replace unemp=	4.8	if	year==	2007	&	mon9	==1	&	st50==1
replace unemp=	4.7	if	year==	2007	&	mon10	==1	&	st50==1
replace unemp=	4.6	if	year==	2007	&	mon11	==1	&	st50==1
replace unemp=	4.5	if	year==	2007	&	mon12	==1	&	st50==1
replace unemp=	4.4	if	year==	2008	&	mon1	==1	&	st50==1
replace unemp=	4.3	if	year==	2008	&	mon2	==1	&	st50==1
replace unemp=	4.3	if	year==	2008	&	mon3	==1	&	st50==1
replace unemp=	4.3	if	year==	2008	&	mon4	==1	&	st50==1
replace unemp=	4.4	if	year==	2008	&	mon5	==1	&	st50==1
replace unemp=	4.6	if	year==	2008	&	mon6	==1	&	st50==1
replace unemp=	4.7	if	year==	2008	&	mon7	==1	&	st50==1
replace unemp=	4.9	if	year==	2008	&	mon8	==1	&	st50==1
replace unemp=	5.1	if	year==	2008	&	mon9	==1	&	st50==1
replace unemp=	5.4	if	year==	2008	&	mon10	==1	&	st50==1
replace unemp=	5.9	if	year==	2008	&	mon11	==1	&	st50==1
replace unemp=	6.5	if	year==	2008	&	mon12	==1	&	st50==1
replace unemp=	7.2	if	year==	2009	&	mon1	==1	&	st50==1
replace unemp=	7.8	if	year==	2009	&	mon2	==1	&	st50==1
replace unemp=	8.4	if	year==	2009	&	mon3	==1	&	st50==1
replace unemp=	8.8	if	year==	2009	&	mon4	==1	&	st50==1
replace unemp=	9	if	year==	2009	&	mon5	==1	&	st50==1
replace unemp=	9.2	if	year==	2009	&	mon6	==1	&	st50==1
replace unemp=	9.2	if	year==	2009	&	mon7	==1	&	st50==1
replace unemp=	9.1	if	year==	2009	&	mon8	==1	&	st50==1
replace unemp=	9.1	if	year==	2009	&	mon9	==1	&	st50==1
replace unemp=	9.1	if	year==	2009	&	mon10	==1	&	st50==1
replace unemp=	9.1	if	year==	2009	&	mon11	==1	&	st50==1
replace unemp=	9.1	if	year==	2009	&	mon12	==1	&	st50==1

replace unemp=	9.2	if	year==	2010	&	mon1	==1	&	st50==1
replace unemp=	9.1	if	year==	2010	&	mon2	==1	&	st50==1
replace unemp=	9	if	year==	2010	&	mon3	==1	&	st50==1
replace unemp=	8.8	if	year==	2010	&	mon4	==1	&	st50==1
replace unemp=	8.5	if	year==	2010	&	mon5	==1	&	st50==1
replace unemp=	8.3	if	year==	2010	&	mon6	==1	&	st50==1
replace unemp=	8.2	if	year==	2010	&	mon7	==1	&	st50==1
replace unemp=	8	if	year==	2010	&	mon8	==1	&	st50==1
replace unemp=	7.9	if	year==	2010	&	mon9	==1	&	st50==1
replace unemp=	7.7	if	year==	2010	&	mon10	==1	&	st50==1
replace unemp=	7.6	if	year==	2010	&	mon11	==1	&	st50==1
replace unemp=	7.5	if	year==	2010	&	mon12	==1	&	st50==1


replace unemp=	2.8	if	year==	2007	&	mon1	==1	&	st51==1
replace unemp=	2.8	if	year==	2007	&	mon2	==1	&	st51==1
replace unemp=	2.8	if	year==	2007	&	mon3	==1	&	st51==1
replace unemp=	2.8	if	year==	2007	&	mon4	==1	&	st51==1
replace unemp=	2.9	if	year==	2007	&	mon5	==1	&	st51==1
replace unemp=	2.9	if	year==	2007	&	mon6	==1	&	st51==1
replace unemp=	2.8	if	year==	2007	&	mon7	==1	&	st51==1
replace unemp=	2.8	if	year==	2007	&	mon8	==1	&	st51==1
replace unemp=	2.7	if	year==	2007	&	mon9	==1	&	st51==1
replace unemp=	2.7	if	year==	2007	&	mon10	==1	&	st51==1
replace unemp=	2.6	if	year==	2007	&	mon11	==1	&	st51==1
replace unemp=	2.6	if	year==	2007	&	mon12	==1	&	st51==1
replace unemp=	2.6	if	year==	2008	&	mon1	==1	&	st51==1
replace unemp=	2.6	if	year==	2008	&	mon2	==1	&	st51==1
replace unemp=	2.7	if	year==	2008	&	mon3	==1	&	st51==1
replace unemp=	2.8	if	year==	2008	&	mon4	==1	&	st51==1
replace unemp=	2.9	if	year==	2008	&	mon5	==1	&	st51==1
replace unemp=	3	if	year==	2008	&	mon6	==1	&	st51==1
replace unemp=	3.2	if	year==	2008	&	mon7	==1	&	st51==1
replace unemp=	3.3	if	year==	2008	&	mon8	==1	&	st51==1
replace unemp=	3.4	if	year==	2008	&	mon9	==1	&	st51==1
replace unemp=	3.5	if	year==	2008	&	mon10	==1	&	st51==1
replace unemp=	3.8	if	year==	2008	&	mon11	==1	&	st51==1
replace unemp=	4.1	if	year==	2008	&	mon12	==1	&	st51==1
replace unemp=	4.4	if	year==	2009	&	mon1	==1	&	st51==1
replace unemp=	4.8	if	year==	2009	&	mon2	==1	&	st51==1
replace unemp=	5.2	if	year==	2009	&	mon3	==1	&	st51==1
replace unemp=	5.7	if	year==	2009	&	mon4	==1	&	st51==1
replace unemp=	6.1	if	year==	2009	&	mon5	==1	&	st51==1
replace unemp=	6.5	if	year==	2009	&	mon6	==1	&	st51==1
replace unemp=	7	if	year==	2009	&	mon7	==1	&	st51==1
replace unemp=	7.3	if	year==	2009	&	mon8	==1	&	st51==1
replace unemp=	7.5	if	year==	2009	&	mon9	==1	&	st51==1
replace unemp=	7.7	if	year==	2009	&	mon10	==1	&	st51==1
replace unemp=	7.7	if	year==	2009	&	mon11	==1	&	st51==1
replace unemp=	7.7	if	year==	2009	&	mon12	==1	&	st51==1


replace unemp=	7.6	if	year==	2010	&	mon1	==1	&	st51==1
replace unemp=	7.5	if	year==	2010	&	mon2	==1	&	st51==1
replace unemp=	7.3	if	year==	2010	&	mon3	==1	&	st51==1
replace unemp=	7.2 if	year==	2010	&	mon4	==1	&	st51==1
replace unemp=	7.1	if	year==	2010	&	mon5	==1	&	st51==1
replace unemp=	7	if	year==	2010	&	mon6	==1	&	st51==1
replace unemp=	6.9	if	year==	2010	&	mon7	==1	&	st51==1
replace unemp=	6.8	if	year==	2010	&	mon8	==1	&	st51==1
replace unemp=	6.7	if	year==	2010	&	mon9	==1	&	st51==1
replace unemp=	6.6	if	year==	2010	&	mon10	==1	&	st51==1
replace unemp=	6.5	if	year==	2010	&	mon11	==1	&	st51==1
replace unemp=	6.4	if	year==	2010	&	mon12	==1	&	st51==1







gen lunemp=ln( unemp)

*Percentage of males in population
*---------------------------------------
gen permale=0
replace permale=	0.48422477	if	year==2007	&	st1	==1
replace permale=	0.520645701	if	year==2007	&	st2	==1
replace permale=	0.501153603	if	year==2007	&	st3	==1
replace permale=	0.489761431	if	year==2007	&	st4	==1
replace permale=	0.500144923	if	year==2007	&	st5	==1
replace permale=	0.503161025	if	year==2007	&	st6	==1
replace permale=	0.487490086	if	year==2007	&	st7	==1
replace permale=	0.485259499	if	year==2007	&	st8	==1
replace permale=	0.471519025	if	year==2007	&	st9	==1
replace permale=	0.491762396	if	year==2007	&	st10	==1
replace permale=	0.491100417	if	year==2007	&	st11	==1
replace permale=	0.504233133	if	year==2007	&	st12	==1
replace permale=	0.493297622	if	year==2007	&	st13	==1
replace permale=	0.502545615	if	year==2007	&	st14	==1
replace permale=	0.492096549	if	year==2007	&	st15	==1
replace permale=	0.492436394	if	year==2007	&	st16	==1
replace permale=	0.495558776	if	year==2007	&	st17	==1
replace permale=	0.490713952	if	year==2007	&	st18	==1
replace permale=	0.486380864	if	year==2007	&	st19	==1
replace permale=	0.485294283	if	year==2007	&	st20	==1
replace permale=	0.484526756	if	year==2007	&	st21	==1
replace permale=	0.488213083	if	year==2007	&	st22	==1
replace permale=	0.491954559	if	year==2007	&	st23	==1
replace permale=	0.497285409	if	year==2007	&	st24	==1
replace permale=	0.488328248	if	year==2007	&	st25	==1
replace permale=	0.484771828	if	year==2007	&	st26	==1
replace permale=	0.500599128	if	year==2007	&	st27	==1
replace permale=	0.488615274	if	year==2007	&	st28	==1
replace permale=	0.502107483	if	year==2007	&	st29	==1
replace permale=	0.495376606	if	year==2007	&	st30	==1
replace permale=	0.492920978	if	year==2007	&	st31	==1
replace permale=	0.489201246	if	year==2007	&	st32	==1
replace permale=	0.494386993	if	year==2007	&	st33	==1
replace permale=	0.509092389	if	year==2007	&	st34	==1
replace permale=	0.485211615	if	year==2007	&	st35	==1
replace permale=	0.487649007	if	year==2007	&	st36	==1
replace permale=	0.493827007	if	year==2007	&	st37	==1
replace permale=	0.495721756	if	year==2007	&	st38	==1
replace permale=	0.486394564	if	year==2007	&	st39	==1
replace permale=	0.484491601	if	year==2007	&	st40	==1
replace permale=	0.487154381	if	year==2007	&	st41	==1
replace permale=	0.498512612	if	year==2007	&	st42	==1
replace permale=	0.487860736	if	year==2007	&	st43	==1
replace permale=	0.498594936	if	year==2007	&	st44	==1
replace permale=	0.503108346	if	year==2007	&	st45	==1
replace permale=	0.491273615	if	year==2007	&	st46	==1
replace permale=	0.491951133	if	year==2007	&	st47	==1
replace permale=	0.498136498	if	year==2007	&	st48	==1
replace permale=	0.496545166	if	year==2007	&	st49	==1
replace permale=	0.489478235	if	year==2007	&	st50	==1
replace permale=	0.507833187	if	year==2007	&	st51	==1
replace permale=	0.484189082	if	year==2008	&	st1	==1
replace permale=	0.522653588	if	year==2008	&	st2	==1
replace permale=	0.501352514	if	year==2008	&	st3	==1
replace permale=	0.489731721	if	year==2008	&	st4	==1
replace permale=	0.500406379	if	year==2008	&	st5	==1
replace permale=	0.503505725	if	year==2008	&	st6	==1
replace permale=	0.487871874	if	year==2008	&	st7	==1
replace permale=	0.485625038	if	year==2008	&	st8	==1
replace permale=	0.471979786	if	year==2008	&	st9	==1
replace permale=	0.491951097	if	year==2008	&	st10	==1
replace permale=	0.491572245	if	year==2008	&	st11	==1
replace permale=	0.505125901	if	year==2008	&	st12	==1
replace permale=	0.493647768	if	year==2008	&	st13	==1
replace permale=	0.502395408	if	year==2008	&	st14	==1
replace permale=	0.49240385	if	year==2008	&	st15	==1
replace permale=	0.492625983	if	year==2008	&	st16	==1
replace permale=	0.49657554	if	year==2008	&	st17	==1
replace permale=	0.489975235	if	year==2008	&	st18	==1
replace permale=	0.485990044	if	year==2008	&	st19	==1
replace permale=	0.48566881	if	year==2008	&	st20	==1
replace permale=	0.484801424	if	year==2008	&	st21	==1
replace permale=	0.488215802	if	year==2008	&	st22	==1
replace permale=	0.491836929	if	year==2008	&	st23	==1
replace permale=	0.497482204	if	year==2008	&	st24	==1
replace permale=	0.48844432	if	year==2008	&	st25	==1
replace permale=	0.484739196	if	year==2008	&	st26	==1
replace permale=	0.500633758	if	year==2008	&	st27	==1
replace permale=	0.489415423	if	year==2008	&	st28	==1
replace permale=	0.502203701	if	year==2008	&	st29	==1
replace permale=	0.495933385	if	year==2008	&	st30	==1
replace permale=	0.493062112	if	year==2008	&	st31	==1
replace permale=	0.489850865	if	year==2008	&	st32	==1
replace permale=	0.494373511	if	year==2008	&	st33	==1
replace permale=	0.509454188	if	year==2008	&	st34	==1
replace permale=	0.4856664	if	year==2008	&	st35	==1
replace permale=	0.487827106	if	year==2008	&	st36	==1
replace permale=	0.493783934	if	year==2008	&	st37	==1
replace permale=	0.495592509	if	year==2008	&	st38	==1
replace permale=	0.486641884	if	year==2008	&	st39	==1
replace permale=	0.485075491	if	year==2008	&	st40	==1
replace permale=	0.487001252	if	year==2008	&	st41	==1
replace permale=	0.498688679	if	year==2008	&	st42	==1
replace permale=	0.487209589	if	year==2008	&	st43	==1
replace permale=	0.499077653	if	year==2008	&	st44	==1
replace permale=	0.502964607	if	year==2008	&	st45	==1
replace permale=	0.491560818	if	year==2008	&	st46	==1
replace permale=	0.492048131	if	year==2008	&	st47	==1
replace permale=	0.499075627	if	year==2008	&	st48	==1
replace permale=	0.496655774	if	year==2008	&	st49	==1
replace permale=	0.489778073	if	year==2008	&	st50	==1
replace permale=	0.508138189	if	year==2008	&	st51	==1
replace permale=	0.484551601	if	year==2009	&	st1	==1
replace permale=	0.518595565	if	year==2009	&	st2	==1
replace permale=	0.501357232	if	year==2009	&	st3	==1
replace permale=	0.489885618	if	year==2009	&	st4	==1
replace permale=	0.500659332	if	year==2009	&	st5	==1
replace permale=	0.503723769	if	year==2009	&	st6	==1
replace permale=	0.488202217	if	year==2009	&	st7	==1
replace permale=	0.485426868	if	year==2009	&	st8	==1
replace permale=	0.472041517	if	year==2009	&	st9	==1
replace permale=	0.49217506	if	year==2009	&	st10	==1
replace permale=	0.491927785	if	year==2009	&	st11	==1
replace permale=	0.505274951	if	year==2009	&	st12	==1
replace permale=	0.493909615	if	year==2009	&	st13	==1
replace permale=	0.501952062	if	year==2009	&	st14	==1
replace permale=	0.492596788	if	year==2009	&	st15	==1
replace permale=	0.492703149	if	year==2009	&	st16	==1
replace permale=	0.496611792	if	year==2009	&	st17	==1
replace permale=	0.490809119	if	year==2009	&	st18	==1
replace permale=	0.486442126	if	year==2009	&	st19	==1
replace permale=	0.486075788	if	year==2009	&	st20	==1
replace permale=	0.484922654	if	year==2009	&	st21	==1
replace permale=	0.488188964	if	year==2009	&	st22	==1
replace permale=	0.491774148	if	year==2009	&	st23	==1
replace permale=	0.497619352	if	year==2009	&	st24	==1
replace permale=	0.488678565	if	year==2009	&	st25	==1
replace permale=	0.484770305	if	year==2009	&	st26	==1
replace permale=	0.50049898	if	year==2009	&	st27	==1
replace permale=	0.489312628	if	year==2009	&	st28	==1
replace permale=	0.502439537	if	year==2009	&	st29	==1
replace permale=	0.496294429	if	year==2009	&	st30	==1
replace permale=	0.492949059	if	year==2009	&	st31	==1
replace permale=	0.49017822	if	year==2009	&	st32	==1
replace permale=	0.494924294	if	year==2009	&	st33	==1
replace permale=	0.509270795	if	year==2009	&	st34	==1
replace permale=	0.486103208	if	year==2009	&	st35	==1
replace permale=	0.488051309	if	year==2009	&	st36	==1
replace permale=	0.494154948	if	year==2009	&	st37	==1
replace permale=	0.495876656	if	year==2009	&	st38	==1
replace permale=	0.487014873	if	year==2009	&	st39	==1
replace permale=	0.485649097	if	year==2009	&	st40	==1
replace permale=	0.486958157	if	year==2009	&	st41	==1
replace permale=	0.499665798	if	year==2009	&	st42	==1
replace permale=	0.487471281	if	year==2009	&	st43	==1
replace permale=	0.499473051	if	year==2009	&	st44	==1
replace permale=	0.503120049	if	year==2009	&	st45	==1
replace permale=	0.491572567	if	year==2009	&	st46	==1
replace permale=	0.492189913	if	year==2009	&	st47	==1
replace permale=	0.49952815	if	year==2009	&	st48	==1
replace permale=	0.496760083	if	year==2009	&	st49	==1
replace permale=	0.490235892	if	year==2009	&	st50	==1
replace permale=	0.509012071	if	year==2009	&	st51	==1


replace permale=	0.485	if	year==2010	&	st1	==1
replace permale=	0.522	if	year==2010	&	st2	==1
replace permale=	0.497	if	year==2010	&	st3	==1
replace permale=	0.49	if	year==2010	&	st4	==1
replace permale=	0.497	if	year==2010	&	st5	==1
replace permale=	0.501	if	year==2010	&	st6	==1
replace permale=	0.486	if	year==2010	&	st7	==1
replace permale=	0.485	if	year==2010	&	st8	==1
replace permale=	0.473	if	year==2010	&	st9	==1
replace permale=	0.489	if	year==2010	&	st10	==1
replace permale=	0.488	if	year==2010	&	st11	==1
replace permale=	0.502	if	year==2010	&	st12	==1
replace permale=	0.501	if	year==2010	&	st13	==1
replace permale=	0.49	if	year==2010	&	st14	==1
replace permale=	0.493	if	year==2010	&	st15	==1
replace permale=	0.494	if	year==2010	&	st16	==1
replace permale=	0.496	if	year==2010	&	st17	==1
replace permale=	0.492	if	year==2010	&	st18	==1
replace permale=	0.49	if	year==2010	&	st19	==1
replace permale=	0.489	if	year==2010	&	st20	==1
replace permale=	0.484	if	year==2010	&	st21	==1
replace permale=	0.483	if	year==2010	&	st22	==1
replace permale=	0.491	if	year==2010	&	st23	==1
replace permale=	0.496	if	year==2010	&	st24	==1
replace permale=	0.485	if	year==2010	&	st25	==1
replace permale=	0.489	if	year==2010	&	st26	==1
replace permale=	0.504	if	year==2010	&	st27	==1
replace permale=	0.495	if	year==2010	&	st28	==1
replace permale=	0.505	if	year==2010	&	st29	==1
replace permale=	0.492	if	year==2010	&	st30	==1
replace permale=	0.487	if	year==2010	&	st31	==1
replace permale=	0.494	if	year==2010	&	st32	==1
replace permale=	0.484	if	year==2010	&	st33	==1
replace permale=	0.487	if	year==2010	&	st34	==1
replace permale=	0.509	if	year==2010	&	st35	==1
replace permale=	0.488	if	year==2010	&	st36	==1
replace permale=	0.493	if	year==2010	&	st37	==1
replace permale=	0.495	if	year==2010	&	st38	==1
replace permale=	0.487	if	year==2010	&	st39	==1
replace permale=	0.483	if	year==2010	&	st40	==1
replace permale=	0.486	if	year==2010	&	st41	==1
replace permale=	0.504	if	year==2010	&	st42	==1
replace permale=	0.487	if	year==2010	&	st43	==1
replace permale=	0.496	if	year==2010	&	st44	==1
replace permale=	0.503	if	year==2010	&	st45	==1
replace permale=	0.492	if	year==2010	&	st46	==1
replace permale=	0.491	if	year==2010	&	st47	==1
replace permale=	0.498	if	year==2010	&	st48	==1
replace permale=	0.493	if	year==2010	&	st49	==1
replace permale=	0.497	if	year==2010	&	st50	==1
replace permale=	0.509	if	year==2010	&	st51	==1



*Gas tax rate
*------------------------------
gen gastax=0
replace gastax=	0.364	if		year==	2007	&	st1	==1		
replace gastax=	0.264	if		year==	2007	&	st2 	==1		
replace gastax=	0.374	if		year==	2007	&	st3	==1		
replace gastax=	0.399	if		year==	2007	&	st4	==1		
replace gastax=	0.376	if		year==	2007	&	st5	==1		
replace gastax=	0.404	if		year==	2007	&	st6	==1		
replace gastax=	0.434	if		year==	2007	&	st7	==1		
replace gastax=	0.414	if		year==	2007	&	st8	==1		
replace gastax=	0.384	if		year==	2007	&	st9	==1		
replace gastax=	0.333	if		year==	2007	&	st10	==1		
replace gastax=	0.259	if		year==	2007	&	st11	==1		
replace gastax=	0.344	if		year==	2007	&	st12	==1		
replace gastax=	0.434	if		year==	2007	&	st13	==1		
replace gastax=	0.374	if		year==	2007	&	st14	==1		
replace gastax=	0.364	if		year==	2007	&	st15	==1		
replace gastax=	0.404	if		year==	2007	&	st16	==1		
replace gastax=	0.434	if		year==	2007	&	st17	==1		
replace gastax=	0.369	if		year==	2007	&	st18	==1		
replace gastax=	0.384	if		year==	2007	&	st19	==1		
replace gastax=	0.452	if		year==	2007	&	st20	==1		
replace gastax=	0.419	if		year==	2007	&	st21	==1		
replace gastax=	0.419	if		year==	2007	&	st22	==1		
replace gastax=	0.38275	if		year==	2007	&	st23	==1		
replace gastax=	0.384	if		year==	2007	&	st24	==1		
replace gastax=	0.368	if		year==	2007	&	st25	==1		
replace gastax=	0.354	if		year==	2007	&	st26	==1		
replace gastax=	0.4615	if		year==	2007	&	st27	==1		
replace gastax=	0.464	if		year==	2007	&	st28	==1		
replace gastax=	0.422	if		year==	2007	&	st29	==1		
replace gastax=	0.38	if		year==	2007	&	st30	==1		
replace gastax=	0.329	if		year==	2007	&	st31	==1		
replace gastax=	0.364	if		year==	2007	&	st32	==1		
replace gastax=	0.5705	if		year==	2007	&	st33	==1		
replace gastax=	0.486	if		year==	2007	&	st34	==1		
replace gastax=	0.414	if		year==	2007	&	st35	==1		
replace gastax=	0.464	if		year==	2007	&	st36	==1		
replace gastax=	0.354	if		year==	2007	&	st37	==1		
replace gastax=	0.424	if		year==	2007	&	st38	==1		
replace gastax=	0.507	if		year==	2007	&	st39	==1		
replace gastax=	0.494	if		year==	2007	&	st40	==1		
replace gastax=	0.352	if		year==	2007	&	st41	==1		
replace gastax=	0.424	if		year==	2007	&	st42	==1		
replace gastax=	0.398	if		year==	2007	&	st43	==1		
replace gastax=	0.384	if		year==	2007	&	st44	==1		
replace gastax=	0.429	if		year==	2007	&	st45	==1		
replace gastax=	0.384	if		year==	2007	&	st46	==1		
replace gastax=	0.359	if		year==	2007	&	st47	==1		
replace gastax=	0.524	if		year==	2007	&	st48	==1		
replace gastax=	0.544	if		year==	2007	&	st48	==2	&	month>6
replace gastax=	0.499	if		year==	2007	&	st49	==1		
replace gastax=	0.513	if		year==	2007	&	st50	==1		
replace gastax=	0.324	if		year==	2007	&	st51	==1		
replace gastax=	0.386	if		year==	2008	&	st1	==1		
replace gastax=	0.264	if		year==	2008	&	st2 	==1		
replace gastax=	0.184	if		year==	2008	&	st2	==1	&	month>8
replace gastax=	0.374	if		year==	2008	&	st3	==1		
replace gastax=	0.402	if		year==	2008	&	st4	==1		
replace gastax=	0.639	if		year==	2008	&	st5	==1		
replace gastax=	0.404	if		year==	2008	&	st6	==1		
replace gastax=	0.625	if		year==	2008	&	st7	==1		
replace gastax=	0.414	if		year==	2008	&	st8	==1		
replace gastax=	0.384	if		year==	2008	&	st9	==1		
replace gastax=	0.516	if		year==	2008	&	st10	==1		
replace gastax=	0.444	if		year==	2008	&	st11	==1		
replace gastax=	0.51	if		year==	2008	&	st12	==1		
replace gastax=	0.434	if		year==	2008	&	st13	==1		
replace gastax=	0.579	if		year==	2008	&	st14	==1		
replace gastax=	0.501	if		year==	2008	&	st15	==1		
replace gastax=	0.401	if		year==	2008	&	st16	==1		
replace gastax=	0.434	if		year==	2008	&	st17	==1		
replace gastax=	0.369	if		year==	2008	&	st18	==1		
replace gastax=	0.384	if		year==	2008	&	st19	==1		
replace gastax=	0.475	if		year==	2008	&	st20	==1		
replace gastax=	0.419	if		year==	2008	&	st21	==1		
replace gastax=	0.419	if		year==	2008	&	st22	==1		
replace gastax=	0.544	if		year==	2008	&	st23	==1		
replace gastax=	0.404	if		year==	2008	&	st24	==1		
replace gastax=	0.372	if		year==	2008	&	st25	==1		
replace gastax=	0.36	if		year==	2008	&	st26	==1		
replace gastax=	0.462	if		year==	2008	&	st27	==1		
replace gastax=	0.423	if		year==	2008	&	st28	==1		
replace gastax=	0.509	if		year==	2008	&	st29	==1		
replace gastax=	0.38	if		year==	2008	&	st30	==1		
replace gastax=	0.329	if		year==	2008	&	st31	==1		
replace gastax=	0.364	if		year==	2008	&	st32	==1		
replace gastax=	0.596	if		year==	2008	&	st33	==1		
replace gastax=	0.486	if		year==	2008	&	st34	==1		
replace gastax=	0.414	if		year==	2008	&	st35	==1		
replace gastax=	0.464	if		year==	2008	&	st36	==1		
replace gastax=	0.354	if		year==	2008	&	st37	==1		
replace gastax=	0.434	if		year==	2008	&	st38	==1		
replace gastax=	0.507	if		year==	2008	&	st39	==1		
replace gastax=	0.494	if		year==	2008	&	st40	==1		
replace gastax=	0.352	if		year==	2008	&	st41	==1		
replace gastax=	0.424	if		year==	2008	&	st42	==1		
replace gastax=	0.398	if		year==	2008	&	st43	==1		
replace gastax=	0.384	if		year==	2008	&	st44	==1		
replace gastax=	0.429	if		year==	2008	&	st45	==1		
replace gastax=	0.384	if		year==	2008	&	st46	==1		
replace gastax=	0.38	if		year==	2008	&	st47	==1		
replace gastax=	0.544	if		year==	2008	&	st48	==1		
replace gastax=	0.559	if		year==	2008	&	st48	==1	&	month>6
replace gastax=	0.499	if		year==	2008	&	st49	==1		
replace gastax=	0.513	if		year==	2008	&	st50	==1		
replace gastax=	0.324	if		year==	2008	&	st51	==1		
replace gastax=	0.393	if		year==	2009	&	st1	==1		
replace gastax=	0.184	if		year==	2009	&	st2	==1	&	month<9
replace gastax=	0.264	if		year==	2009	&	st2 	==1		
replace gastax=	0.374	if		year==	2009	&	st3	==1		
replace gastax=	0.402	if		year==	2009	&	st4	==1		
replace gastax=	0.583	if		year==	2009	&	st5	==1		
replace gastax=	0.404	if		year==	2009	&	st6	==1		
replace gastax=	0.548	if		year==	2009	&	st7	==1		
replace gastax=	0.414	if		year==	2009	&	st8	==1		
replace gastax=	0.384	if		year==	2009	&	st9	==1		
replace gastax=	0.529	if		year==	2009	&	st10	==1		
replace gastax=	0.308	if		year==	2009	&	st11	==1		
replace gastax=	0.52	if		year==	2009	&	st12	==1		
replace gastax=	0.434	if		year==	2009	&	st13	==1		
replace gastax=	0.522	if		year==	2009	&	st14	==1		
replace gastax=	0.481	if		year==	2009	&	st15	==1		
replace gastax=	0.404	if		year==	2009	&	st16	==1		
replace gastax=	0.434	if		year==	2009	&	st17	==1		
replace gastax=	0.409	if		year==	2009	&	st18	==1		
replace gastax=	0.384	if		year==	2009	&	st19	==1		
replace gastax=	0.483	if		year==	2009	&	st20	==1		
replace gastax=	0.419	if		year==	2009	&	st21	==1		
replace gastax=	0.419	if		year==	2009	&	st22	==1		
replace gastax=	0.493	if		year==	2009	&	st23	==1		
replace gastax=	0.44	if		year==	2009	&	st24	==1		
replace gastax=	0.372	if		year==	2009	&	st25	==1		
replace gastax=	0.357	if		year==	2009	&	st26	==1		
replace gastax=	0.462	if		year==	2009	&	st27	==1		
replace gastax=	0.457	if		year==	2009	&	st28	==1		
replace gastax=	0.515	if		year==	2009	&	st29	==1		
replace gastax=	0.38	if		year==	2009	&	st30	==1		
replace gastax=	0.329	if		year==	2009	&	st31	==1		
replace gastax=	0.372	if		year==	2009	&	st32	==1		
replace gastax=	0.609	if		year==	2009	&	st33	==1		
replace gastax=	0.486	if		year==	2009	&	st34	==1		
replace gastax=	0.414	if		year==	2009	&	st35	==1		
replace gastax=	0.464	if		year==	2009	&	st36	==1		
replace gastax=	0.354	if		year==	2009	&	st37	==1		
replace gastax=	0.434	if		year==	2009	&	st38	==1		
replace gastax=	0.507	if		year==	2009	&	st39	==1		
replace gastax=	0.494	if		year==	2009	&	st40	==1		
replace gastax=	0.352	if		year==	2009	&	st41	==1		
replace gastax=	0.424	if		year==	2009	&	st42	==1		
replace gastax=	0.398	if		year==	2009	&	st43	==1		
replace gastax=	0.384	if		year==	2009	&	st44	==1		
replace gastax=	0.429	if		year==	2009	&	st45	==1		
replace gastax=	0.384	if		year==	2009	&	st46	==1		
replace gastax=	0.375	if		year==	2009	&	st47	==1		
replace gastax=	0.559	if		year==	2009	&	st48	==1		
replace gastax=	0.506	if		year==	2009	&	st49	==1		
replace gastax=	0.513	if		year==	2009	&	st50	==1		
replace gastax=	0.324	if		year==	2009	&	st51	==1		
replace gastax=	0.393	if		year==	2010	&	st1	==1		
replace gastax=	0.264	if		year==	2010	&	st2 	==1		
replace gastax=	0.374	if		year==	2010	&	st3	==1		
replace gastax=	0.402	if		year==	2010	&	st4	==1		
replace gastax=	0.65	if		year==	2010	&	st5	==1		
replace gastax=	0.404	if		year==	2010	&	st6	==1		
replace gastax=	0.603	if		year==	2010	&	st7	==1		
replace gastax=	0.414	if		year==	2010	&	st8	==1		
replace gastax=	0.419	if		year==	2010	&	st9	==1		
replace gastax=	0.529	if		year==	2010	&	st10	==1		
replace gastax=	0.308	if		year==	2010	&	st11	==1		
replace gastax=	0.628	if		year==	2010	&	st12	==1		
replace gastax=	0.434	if		year==	2010	&	st13	==1		
replace gastax=	0.574	if		year==	2010	&	st14	==1		
replace gastax=	0.525	if		year==	2010	&	st15	==1		
replace gastax=	0.404	if		year==	2010	&	st16	==1		
replace gastax=	0.434	if		year==	2010	&	st17	==1		
replace gastax=	0.409	if		year==	2010	&	st18	==1		
replace gastax=	0.384	if		year==	2010	&	st19	==1		
replace gastax=	0.494	if		year==	2010	&	st20	==1		
replace gastax=	0.419	if		year==	2010	&	st21	==1		
replace gastax=	0.419	if		year==	2010	&	st22	==1		
replace gastax=	0.534	if		year==	2010	&	st23	==1		
replace gastax=	0.456	if		year==	2010	&	st24	==1		
replace gastax=	0.372	if		year==	2010	&	st25	==1		
replace gastax=	0.357	if		year==	2010	&	st26	==1		
replace gastax=	0.462	if		year==	2010	&	st27	==1		
replace gastax=	0.461	if		year==	2010	&	st28	==1		
replace gastax=	0.515	if		year==	2010	&	st29	==1		
replace gastax=	0.38	if		year==	2010	&	st30	==1		
replace gastax=	0.329	if		year==	2010	&	st31	==1		
replace gastax=	0.372	if		year==	2010	&	st32	==1		
replace gastax=	0.63	if		year==	2010	&	st33	==1		
replace gastax=	0.486	if		year==	2010	&	st34	==1		
replace gastax=	0.414	if		year==	2010	&	st35	==1		
replace gastax=	0.464	if		year==	2010	&	st36	==1		
replace gastax=	0.354	if		year==	2010	&	st37	==1		
replace gastax=	0.434	if		year==	2010	&	st38	==1		
replace gastax=	0.507	if		year==	2010	&	st39	==1		
replace gastax=	0.514	if		year==	2010	&	st40	==1		
replace gastax=	0.352	if		year==	2010	&	st41	==1		
replace gastax=	0.424	if		year==	2010	&	st42	==1		
replace gastax=	0.398	if		year==	2010	&	st43	==1		
replace gastax=	0.384	if		year==	2010	&	st44	==1		
replace gastax=	0.429	if		year==	2010	&	st45	==1		
replace gastax=	0.429	if		year==	2010	&	st46	==1		
replace gastax=	0.379	if		year==	2010	&	st47	==1		
replace gastax=	0.559	if		year==	2010	&	st48	==1		
replace gastax=	0.506	if		year==	2010	&	st49	==1		
replace gastax=	0.513	if		year==	2010	&	st50	==1		
replace gastax=	0.324	if		year==	2010	&	st51	==1	

gen lgastax=ln(gastax)


*CPI index
*-------------------------------
gen cpi=0
replace cpi=	202.416	if	year==2007	&	mon1	==1
replace cpi=	203.499	if	year==2007	&	mon2	==1
replace cpi=	205.352	if	year==2007	&	mon3	==1
replace cpi=	206.686	if	year==2007	&	mon4	==1
replace cpi=	207.949	if	year==2007	&	mon5	==1
replace cpi=	208.352	if	year==2007	&	mon6	==1
replace cpi=	208.299	if	year==2007	&	mon7	==1
replace cpi=	207.917	if	year==2007	&	mon8	==1
replace cpi=	208.49	if	year==2007	&	mon9	==1
replace cpi=	208.936	if	year==2007	&	mon10	==1
replace cpi=	210.177	if	year==2007	&	mon11	==1
replace cpi=	210.036	if	year==2007	&	mon12	==1
replace cpi=	211.08	if	year==2008	&	mon1	==1
replace cpi=	211.693	if	year==2008	&	mon2	==1
replace cpi=	213.528	if	year==2008	&	mon3	==1
replace cpi=	214.823	if	year==2008	&	mon4	==1
replace cpi=	216.632	if	year==2008	&	mon5	==1
replace cpi=	218.815	if	year==2008	&	mon6	==1
replace cpi=	219.964	if	year==2008	&	mon7	==1
replace cpi=	219.086	if	year==2008	&	mon8	==1
replace cpi=	218.783	if	year==2008	&	mon9	==1
replace cpi=	216.573	if	year==2008	&	mon10	==1
replace cpi=	212.425	if	year==2008	&	mon11	==1
replace cpi=	210.228	if	year==2008	&	mon12	==1
replace cpi=	211.143	if	year==2009	&	mon1	==1
replace cpi=	212.193	if	year==2009	&	mon2	==1
replace cpi=	212.709	if	year==2009	&	mon3	==1
replace cpi=	213.24	if	year==2009	&	mon4	==1
replace cpi=	213.856	if	year==2009	&	mon5	==1
replace cpi=	215.693	if	year==2009	&	mon6	==1
replace cpi=	215.351	if	year==2009	&	mon7	==1
replace cpi=	215.834	if	year==2009	&	mon8	==1
replace cpi=	215.969	if	year==2009	&	mon9	==1
replace cpi=	216.177	if	year==2009	&	mon10	==1
replace cpi=	216.33	if	year==2009	&	mon11	==1
replace cpi=	215.949	if	year==2009	&	mon12	==1
replace cpi=	216.687	if	year==2010	&	mon1	==1
replace cpi=	216.741	if	year==2010	&	mon2	==1
replace cpi=	217.631	if	year==2010	&	mon3	==1
replace cpi=	218.009	if	year==2010	&	mon4	==1
replace cpi=	218.178	if	year==2010	&	mon5	==1
replace cpi=	217.965	if	year==2010	&	mon6	==1
replace cpi=	218.011	if	year==2010	&	mon7	==1
replace cpi=	218.312	if	year==2010	&	mon8	==1
replace cpi=	218.439	if	year==2010	&	mon9	==1
replace cpi=	218.711	if	year==2010	&	mon10	==1
replace cpi=	218.803	if	year==2010	&	mon11	==1
replace cpi=	219.179	if	year==2010	&	mon12	==1





*Vehicle Mile Traveled
*----------------------------
*----------------------------
gen vmt=0 							
replace vmt=	4684	if	st1	==1	&	t1	==1
replace vmt=	325	if	st2 	==1	&	t1	==1
replace vmt=	4817	if	st3	==1	&	t1	==1
replace vmt=	2520	if	st4	==1	&	t1	==1
replace vmt=	22434	if	st5	==1	&	t1	==1
replace vmt=	3646	if	st6	==1	&	t1	==1
replace vmt=	2444	if	st7	==1	&	t1	==1
replace vmt=	687	if	st8	==1	&	t1	==1
replace vmt=	311	if	st9	==1	&	t1	==1
replace vmt=	17503	if	st10	==1	&	t1	==1
replace vmt=	9151	if	st11	==1	&	t1	==1
replace vmt=	804	if	st12	==1	&	t1	==1
replace vmt=	1123	if	st13	==1	&	t1	==1
replace vmt=	7800	if	st14	==1	&	t1	==1
replace vmt=	5742	if	st15	==1	&	t1	==1
replace vmt=	2257	if	st16	==1	&	t1	==1
replace vmt=	2117	if	st17	==1	&	t1	==1
replace vmt=	3543	if	st18	==1	&	t1	==1
replace vmt=	3498	if	st19	==1	&	t1	==1
replace vmt=	1127	if	st20	==1	&	t1	==1
replace vmt=	4247	if	st21	==1	&	t1	==1
replace vmt=	4753	if	st22	==1	&	t1	==1
replace vmt=	8602	if	st23	==1	&	t1	==1
replace vmt=	4343	if	st24	==1	&	t1	==1
replace vmt=	2955	if	st25	==1	&	t1	==1
replace vmt=	5085	if	st26	==1	&	t1	==1
replace vmt=	843	if	st27	==1	&	t1	==1
replace vmt=	1361	if	st28	==1	&	t1	==1
replace vmt=	1569	if	st29	==1	&	t1	==1
replace vmt=	1018	if	st30	==1	&	t1	==1
replace vmt=	5474	if	st31	==1	&	t1	==1
replace vmt=	1975	if	st32	==1	&	t1	==1
replace vmt=	10815	if	st33	==1	&	t1	==1
replace vmt=	8257	if	st34	==1	&	t1	==1
replace vmt=	547	if	st35	==1	&	t1	==1
replace vmt=	8577	if	st36	==1	&	t1	==1
replace vmt=	3366	if	st37	==1	&	t1	==1
replace vmt=	2501	if	st38	==1	&	t1	==1
replace vmt=	7656	if	st39	==1	&	t1	==1
replace vmt=	453	if	st40	==1	&	t1	==1
replace vmt=	4015	if	st41	==1	&	t1	==1
replace vmt=	584	if	st42	==1	&	t1	==1
replace vmt=	5740	if	st43	==1	&	t1	==1
replace vmt=	18445	if	st44	==1	&	t1	==1
replace vmt=	1983	if	st45	==1	&	t1	==1
replace vmt=	620	if	st46	==1	&	t1	==1
replace vmt=	6281	if	st47	==1	&	t1	==1
replace vmt=	4021	if	st48	==1	&	t1	==1
replace vmt=	1468	if	st49	==1	&	t1	==1
replace vmt=	4401	if	st50	==1	&	t1	==1
replace vmt=	634	if	st51	==1	&	t1	==1
replace vmt=	4540	if	st1	==1	&	t2	==1
replace vmt=	325	if	st2 	==1	&	t2	==1
replace vmt=	4966	if	st3	==1	&	t2	==1
replace vmt=	2227	if	st4	==1	&	t2	==1
replace vmt=	23455	if	st5	==1	&	t2	==1
replace vmt=	3399	if	st6	==1	&	t2	==1
replace vmt=	2170	if	st7	==1	&	t2	==1
replace vmt=	623	if	st8	==1	&	t2	==1
replace vmt=	264	if	st9	==1	&	t2	==1
replace vmt=	15922	if	st10	==1	&	t2	==1
replace vmt=	9085	if	st11	==1	&	t2	==1
replace vmt=	645	if	st12	==1	&	t2	==1
replace vmt=	1093	if	st13	==1	&	t2	==1
replace vmt=	7502	if	st14	==1	&	t2	==1
replace vmt=	4887	if	st15	==1	&	t2	==1
replace vmt=	2025	if	st16	==1	&	t2	==1
replace vmt=	2163	if	st17	==1	&	t2	==1
replace vmt=	3233	if	st18	==1	&	t2	==1
replace vmt=	3232	if	st19	==1	&	t2	==1
replace vmt=	1080	if	st20	==1	&	t2	==1
replace vmt=	3697	if	st21	==1	&	t2	==1
replace vmt=	4119	if	st22	==1	&	t2	==1
replace vmt=	7386	if	st23	==1	&	t2	==1
replace vmt=	3855	if	st24	==1	&	t2	==1
replace vmt=	3002	if	st25	==1	&	t2	==1
replace vmt=	4683	if	st26	==1	&	t2	==1
replace vmt=	786	if	st27	==1	&	t2	==1
replace vmt=	1303	if	st28	==1	&	t2	==1
replace vmt=	1466	if	st29	==1	&	t2	==1
replace vmt=	985	if	st30	==1	&	t2	==1
replace vmt=	5035	if	st31	==1	&	t2	==1
replace vmt=	1852	if	st32	==1	&	t2	==1
replace vmt=	9745	if	st33	==1	&	t2	==1
replace vmt=	7653	if	st34	==1	&	t2	==1
replace vmt=	488	if	st35	==1	&	t2	==1
replace vmt=	7421	if	st36	==1	&	t2	==1
replace vmt=	3372	if	st37	==1	&	t2	==1
replace vmt=	2480	if	st38	==1	&	t2	==1
replace vmt=	7091	if	st39	==1	&	t2	==1
replace vmt=	585	if	st40	==1	&	t2	==1
replace vmt=	3834	if	st41	==1	&	t2	==1
replace vmt=	525	if	st42	==1	&	t2	==1
replace vmt=	5224	if	st43	==1	&	t2	==1
replace vmt=	17893	if	st44	==1	&	t2	==1
replace vmt=	1839	if	st45	==1	&	t2	==1
replace vmt=	603	if	st46	==1	&	t2	==1
replace vmt=	5707	if	st47	==1	&	t2	==1
replace vmt=	3720	if	st48	==1	&	t2	==1
replace vmt=	1131	if	st49	==1	&	t2	==1
replace vmt=	4078	if	st50	==1	&	t2	==1
replace vmt=	613	if	st51	==1	&	t2	==1
replace vmt=	5307	if	st1	==1	&	t3	==1
replace vmt=	381	if	st2 	==1	&	t3	==1
replace vmt=	5154	if	st3	==1	&	t3	==1
replace vmt=	2761	if	st4	==1	&	t3	==1
replace vmt=	27738	if	st5	==1	&	t3	==1
replace vmt=	4356	if	st6	==1	&	t3	==1
replace vmt=	2537	if	st7	==1	&	t3	==1
replace vmt=	742	if	st8	==1	&	t3	==1
replace vmt=	319	if	st9	==1	&	t3	==1
replace vmt=	18586	if	st10	==1	&	t3	==1
replace vmt=	10267	if	st11	==1	&	t3	==1
replace vmt=	728	if	st12	==1	&	t3	==1
replace vmt=	1279	if	st13	==1	&	t3	==1
replace vmt=	8686	if	st14	==1	&	t3	==1
replace vmt=	6028	if	st15	==1	&	t3	==1
replace vmt=	2448	if	st16	==1	&	t3	==1
replace vmt=	2548	if	st17	==1	&	t3	==1
replace vmt=	4038	if	st18	==1	&	t3	==1
replace vmt=	3791	if	st19	==1	&	t3	==1
replace vmt=	1219	if	st20	==1	&	t3	==1
replace vmt=	4690	if	st21	==1	&	t3	==1
replace vmt=	4411	if	st22	==1	&	t3	==1
replace vmt=	8756	if	st23	==1	&	t3	==1
replace vmt=	4518	if	st24	==1	&	t3	==1
replace vmt=	3642	if	st25	==1	&	t3	==1
replace vmt=	5699	if	st26	==1	&	t3	==1
replace vmt=	983	if	st27	==1	&	t3	==1
replace vmt=	1595	if	st28	==1	&	t3	==1
replace vmt=	1808	if	st29	==1	&	t3	==1
replace vmt=	1121	if	st30	==1	&	t3	==1
replace vmt=	6354	if	st31	==1	&	t3	==1
replace vmt=	2072	if	st32	==1	&	t3	==1
replace vmt=	11761	if	st33	==1	&	t3	==1
replace vmt=	8955	if	st34	==1	&	t3	==1
replace vmt=	608	if	st35	==1	&	t3	==1
replace vmt=	9059	if	st36	==1	&	t3	==1
replace vmt=	4144	if	st37	==1	&	t3	==1
replace vmt=	2941	if	st38	==1	&	t3	==1
replace vmt=	8529	if	st39	==1	&	t3	==1
replace vmt=	611	if	st40	==1	&	t3	==1
replace vmt=	4485	if	st41	==1	&	t3	==1
replace vmt=	641	if	st42	==1	&	t3	==1
replace vmt=	6197	if	st43	==1	&	t3	==1
replace vmt=	21324	if	st44	==1	&	t3	==1
replace vmt=	2325	if	st45	==1	&	t3	==1
replace vmt=	647	if	st46	==1	&	t3	==1
replace vmt=	6836	if	st47	==1	&	t3	==1
replace vmt=	4451	if	st48	==1	&	t3	==1
replace vmt=	1792	if	st49	==1	&	t3	==1
replace vmt=	5009	if	st50	==1	&	t3	==1
replace vmt=	707	if	st51	==1	&	t3	==1
replace vmt=	5188	if	st1	==1	&	t4	==1
replace vmt=	428	if	st2 	==1	&	t4	==1
replace vmt=	5233	if	st3	==1	&	t4	==1
replace vmt=	2455	if	st4	==1	&	t4	==1
replace vmt=	27859	if	st5	==1	&	t4	==1
replace vmt=	4029	if	st6	==1	&	t4	==1
replace vmt=	2547	if	st7	==1	&	t4	==1
replace vmt=	739	if	st8	==1	&	t4	==1
replace vmt=	298	if	st9	==1	&	t4	==1
replace vmt=	17292	if	st10	==1	&	t4	==1
replace vmt=	10016	if	st11	==1	&	t4	==1
replace vmt=	762	if	st12	==1	&	t4	==1
replace vmt=	1256	if	st13	==1	&	t4	==1
replace vmt=	9035	if	st14	==1	&	t4	==1
replace vmt=	5975	if	st15	==1	&	t4	==1
replace vmt=	2604	if	st16	==1	&	t4	==1
replace vmt=	2422	if	st17	==1	&	t4	==1
replace vmt=	4009	if	st18	==1	&	t4	==1
replace vmt=	3713	if	st19	==1	&	t4	==1
replace vmt=	1131	if	st20	==1	&	t4	==1
replace vmt=	4583	if	st21	==1	&	t4	==1
replace vmt=	4056	if	st22	==1	&	t4	==1
replace vmt=	8346	if	st23	==1	&	t4	==1
replace vmt=	4592	if	st24	==1	&	t4	==1
replace vmt=	3494	if	st25	==1	&	t4	==1
replace vmt=	5664	if	st26	==1	&	t4	==1
replace vmt=	964	if	st27	==1	&	t4	==1
replace vmt=	1579	if	st28	==1	&	t4	==1
replace vmt=	1721	if	st29	==1	&	t4	==1
replace vmt=	1052	if	st30	==1	&	t4	==1
replace vmt=	5964	if	st31	==1	&	t4	==1
replace vmt=	1949	if	st32	==1	&	t4	==1
replace vmt=	11130	if	st33	==1	&	t4	==1
replace vmt=	8587	if	st34	==1	&	t4	==1
replace vmt=	640	if	st35	==1	&	t4	==1
replace vmt=	8711	if	st36	==1	&	t4	==1
replace vmt=	3964	if	st37	==1	&	t4	==1
replace vmt=	2837	if	st38	==1	&	t4	==1
replace vmt=	8604	if	st39	==1	&	t4	==1
replace vmt=	637	if	st40	==1	&	t4	==1
replace vmt=	4303	if	st41	==1	&	t4	==1
replace vmt=	667	if	st42	==1	&	t4	==1
replace vmt=	6015	if	st43	==1	&	t4	==1
replace vmt=	19265	if	st44	==1	&	t4	==1
replace vmt=	2258	if	st45	==1	&	t4	==1
replace vmt=	562	if	st46	==1	&	t4	==1
replace vmt=	6708	if	st47	==1	&	t4	==1
replace vmt=	4766	if	st48	==1	&	t4	==1
replace vmt=	1702	if	st49	==1	&	t4	==1
replace vmt=	4866	if	st50	==1	&	t4	==1
replace vmt=	734	if	st51	==1	&	t4	==1
replace vmt=	5306	if	st1	==1	&	t5	==1
replace vmt=	500	if	st2 	==1	&	t5	==1
replace vmt=	5403	if	st3	==1	&	t5	==1
replace vmt=	2826	if	st4	==1	&	t5	==1
replace vmt=	28596	if	st5	==1	&	t5	==1
replace vmt=	4124	if	st6	==1	&	t5	==1
replace vmt=	2832	if	st7	==1	&	t5	==1
replace vmt=	826	if	st8	==1	&	t5	==1
replace vmt=	327	if	st9	==1	&	t5	==1
replace vmt=	17695	if	st10	==1	&	t5	==1
replace vmt=	10552	if	st11	==1	&	t5	==1
replace vmt=	633	if	st12	==1	&	t5	==1
replace vmt=	1335	if	st13	==1	&	t5	==1
replace vmt=	9847	if	st14	==1	&	t5	==1
replace vmt=	6253	if	st15	==1	&	t5	==1
replace vmt=	2835	if	st16	==1	&	t5	==1
replace vmt=	2615	if	st17	==1	&	t5	==1
replace vmt=	4289	if	st18	==1	&	t5	==1
replace vmt=	3901	if	st19	==1	&	t5	==1
replace vmt=	1313	if	st20	==1	&	t5	==1
replace vmt=	5191	if	st21	==1	&	t5	==1
replace vmt=	4340	if	st22	==1	&	t5	==1
replace vmt=	9252	if	st23	==1	&	t5	==1
replace vmt=	4990	if	st24	==1	&	t5	==1
replace vmt=	3957	if	st25	==1	&	t5	==1
replace vmt=	6314	if	st26	==1	&	t5	==1
replace vmt=	1015	if	st27	==1	&	t5	==1
replace vmt=	1736	if	st28	==1	&	t5	==1
replace vmt=	2034	if	st29	==1	&	t5	==1
replace vmt=	1257	if	st30	==1	&	t5	==1
replace vmt=	6310	if	st31	==1	&	t5	==1
replace vmt=	2145	if	st32	==1	&	t5	==1
replace vmt=	12405	if	st33	==1	&	t5	==1
replace vmt=	9030	if	st34	==1	&	t5	==1
replace vmt=	673	if	st35	==1	&	t5	==1
replace vmt=	9612	if	st36	==1	&	t5	==1
replace vmt=	4237	if	st37	==1	&	t5	==1
replace vmt=	3083	if	st38	==1	&	t5	==1
replace vmt=	9385	if	st39	==1	&	t5	==1
replace vmt=	728	if	st40	==1	&	t5	==1
replace vmt=	4682	if	st41	==1	&	t5	==1
replace vmt=	759	if	st42	==1	&	t5	==1
replace vmt=	6241	if	st43	==1	&	t5	==1
replace vmt=	20349	if	st44	==1	&	t5	==1
replace vmt=	2213	if	st45	==1	&	t5	==1
replace vmt=	666	if	st46	==1	&	t5	==1
replace vmt=	7218	if	st47	==1	&	t5	==1
replace vmt=	5100	if	st48	==1	&	t5	==1
replace vmt=	1810	if	st49	==1	&	t5	==1
replace vmt=	5430	if	st50	==1	&	t5	==1
replace vmt=	795	if	st51	==1	&	t5	==1
replace vmt=	5233	if	st1	==1	&	t6	==1
replace vmt=	473	if	st2 	==1	&	t6	==1
replace vmt=	5396	if	st3	==1	&	t6	==1
replace vmt=	2711	if	st4	==1	&	t6	==1
replace vmt=	29825	if	st5	==1	&	t6	==1
replace vmt=	3749	if	st6	==1	&	t6	==1
replace vmt=	2728	if	st7	==1	&	t6	==1
replace vmt=	924	if	st8	==1	&	t6	==1
replace vmt=	332	if	st9	==1	&	t6	==1
replace vmt=	16748	if	st10	==1	&	t6	==1
replace vmt=	9425	if	st11	==1	&	t6	==1
replace vmt=	772	if	st12	==1	&	t6	==1
replace vmt=	1384	if	st13	==1	&	t6	==1
replace vmt=	9921	if	st14	==1	&	t6	==1
replace vmt=	5890	if	st15	==1	&	t6	==1
replace vmt=	2799	if	st16	==1	&	t6	==1
replace vmt=	2493	if	st17	==1	&	t6	==1
replace vmt=	4147	if	st18	==1	&	t6	==1
replace vmt=	4013	if	st19	==1	&	t6	==1
replace vmt=	1302	if	st20	==1	&	t6	==1
replace vmt=	5035	if	st21	==1	&	t6	==1
replace vmt=	4882	if	st22	==1	&	t6	==1
replace vmt=	8816	if	st23	==1	&	t6	==1
replace vmt=	5104	if	st24	==1	&	t6	==1
replace vmt=	3598	if	st25	==1	&	t6	==1
replace vmt=	6018	if	st26	==1	&	t6	==1
replace vmt=	1158	if	st27	==1	&	t6	==1
replace vmt=	1730	if	st28	==1	&	t6	==1
replace vmt=	1721	if	st29	==1	&	t6	==1
replace vmt=	1121	if	st30	==1	&	t6	==1
replace vmt=	6402	if	st31	==1	&	t6	==1
replace vmt=	2017	if	st32	==1	&	t6	==1
replace vmt=	12066	if	st33	==1	&	t6	==1
replace vmt=	8897	if	st34	==1	&	t6	==1
replace vmt=	711	if	st35	==1	&	t6	==1
replace vmt=	9571	if	st36	==1	&	t6	==1
replace vmt=	3984	if	st37	==1	&	t6	==1
replace vmt=	3118	if	st38	==1	&	t6	==1
replace vmt=	9379	if	st39	==1	&	t6	==1
replace vmt=	735	if	st40	==1	&	t6	==1
replace vmt=	4288	if	st41	==1	&	t6	==1
replace vmt=	794	if	st42	==1	&	t6	==1
replace vmt=	6101	if	st43	==1	&	t6	==1
replace vmt=	19914	if	st44	==1	&	t6	==1
replace vmt=	2245	if	st45	==1	&	t6	==1
replace vmt=	633	if	st46	==1	&	t6	==1
replace vmt=	7101	if	st47	==1	&	t6	==1
replace vmt=	5037	if	st48	==1	&	t6	==1
replace vmt=	1826	if	st49	==1	&	t6	==1
replace vmt=	5236	if	st50	==1	&	t6	==1
replace vmt=	837	if	st51	==1	&	t6	==1
replace vmt=	5235	if	st1	==1	&	t7	==1
replace vmt=	487	if	st2 	==1	&	t7	==1
replace vmt=	4719	if	st3	==1	&	t7	==1
replace vmt=	2867	if	st4	==1	&	t7	==1
replace vmt=	29490	if	st5	==1	&	t7	==1
replace vmt=	3842	if	st6	==1	&	t7	==1
replace vmt=	2799	if	st7	==1	&	t7	==1
replace vmt=	931	if	st8	==1	&	t7	==1
replace vmt=	339	if	st9	==1	&	t7	==1
replace vmt=	16902	if	st10	==1	&	t7	==1
replace vmt=	9498	if	st11	==1	&	t7	==1
replace vmt=	816	if	st12	==1	&	t7	==1
replace vmt=	1482	if	st13	==1	&	t7	==1
replace vmt=	9211	if	st14	==1	&	t7	==1
replace vmt=	6123	if	st15	==1	&	t7	==1
replace vmt=	2776	if	st16	==1	&	t7	==1
replace vmt=	2568	if	st17	==1	&	t7	==1
replace vmt=	4201	if	st18	==1	&	t7	==1
replace vmt=	4007	if	st19	==1	&	t7	==1
replace vmt=	1345	if	st20	==1	&	t7	==1
replace vmt=	4890	if	st21	==1	&	t7	==1
replace vmt=	5021	if	st22	==1	&	t7	==1
replace vmt=	8893	if	st23	==1	&	t7	==1
replace vmt=	5003	if	st24	==1	&	t7	==1
replace vmt=	3592	if	st25	==1	&	t7	==1
replace vmt=	6074	if	st26	==1	&	t7	==1
replace vmt=	1228	if	st27	==1	&	t7	==1
replace vmt=	1772	if	st28	==1	&	t7	==1
replace vmt=	1772	if	st29	==1	&	t7	==1
replace vmt=	1180	if	st30	==1	&	t7	==1
replace vmt=	6121	if	st31	==1	&	t7	==1
replace vmt=	2165	if	st32	==1	&	t7	==1
replace vmt=	11903	if	st33	==1	&	t7	==1
replace vmt=	8877	if	st34	==1	&	t7	==1
replace vmt=	802	if	st35	==1	&	t7	==1
replace vmt=	9670	if	st36	==1	&	t7	==1
replace vmt=	4273	if	st37	==1	&	t7	==1
replace vmt=	3385	if	st38	==1	&	t7	==1
replace vmt=	9620	if	st39	==1	&	t7	==1
replace vmt=	780	if	st40	==1	&	t7	==1
replace vmt=	4412	if	st41	==1	&	t7	==1
replace vmt=	874	if	st42	==1	&	t7	==1
replace vmt=	6555	if	st43	==1	&	t7	==1
replace vmt=	20152	if	st44	==1	&	t7	==1
replace vmt=	2401	if	st45	==1	&	t7	==1
replace vmt=	706	if	st46	==1	&	t7	==1
replace vmt=	7244	if	st47	==1	&	t7	==1
replace vmt=	5269	if	st48	==1	&	t7	==1
replace vmt=	1737	if	st49	==1	&	t7	==1
replace vmt=	5386	if	st50	==1	&	t7	==1
replace vmt=	936	if	st51	==1	&	t7	==1
replace vmt=	5534	if	st1	==1	&	t8	==1
replace vmt=	486	if	st2 	==1	&	t8	==1
replace vmt=	4722	if	st3	==1	&	t8	==1
replace vmt=	2827	if	st4	==1	&	t8	==1
replace vmt=	29496	if	st5	==1	&	t8	==1
replace vmt=	4388	if	st6	==1	&	t8	==1
replace vmt=	2852	if	st7	==1	&	t8	==1
replace vmt=	907	if	st8	==1	&	t8	==1
replace vmt=	332	if	st9	==1	&	t8	==1
replace vmt=	17561	if	st10	==1	&	t8	==1
replace vmt=	9680	if	st11	==1	&	t8	==1
replace vmt=	849	if	st12	==1	&	t8	==1
replace vmt=	1477	if	st13	==1	&	t8	==1
replace vmt=	9399	if	st14	==1	&	t8	==1
replace vmt=	5809	if	st15	==1	&	t8	==1
replace vmt=	2792	if	st16	==1	&	t8	==1
replace vmt=	2299	if	st17	==1	&	t8	==1
replace vmt=	4270	if	st18	==1	&	t8	==1
replace vmt=	4430	if	st19	==1	&	t8	==1
replace vmt=	1414	if	st20	==1	&	t8	==1
replace vmt=	5338	if	st21	==1	&	t8	==1
replace vmt=	5109	if	st22	==1	&	t8	==1
replace vmt=	9266	if	st23	==1	&	t8	==1
replace vmt=	5200	if	st24	==1	&	t8	==1
replace vmt=	3876	if	st25	==1	&	t8	==1
replace vmt=	6289	if	st26	==1	&	t8	==1
replace vmt=	1206	if	st27	==1	&	t8	==1
replace vmt=	1797	if	st28	==1	&	t8	==1
replace vmt=	1875	if	st29	==1	&	t8	==1
replace vmt=	1428	if	st30	==1	&	t8	==1
replace vmt=	6243	if	st31	==1	&	t8	==1
replace vmt=	2056	if	st32	==1	&	t8	==1
replace vmt=	13045	if	st33	==1	&	t8	==1
replace vmt=	8805	if	st34	==1	&	t8	==1
replace vmt=	754	if	st35	==1	&	t8	==1
replace vmt=	9523	if	st36	==1	&	t8	==1
replace vmt=	4381	if	st37	==1	&	t8	==1
replace vmt=	3511	if	st38	==1	&	t8	==1
replace vmt=	9972	if	st39	==1	&	t8	==1
replace vmt=	853	if	st40	==1	&	t8	==1
replace vmt=	4649	if	st41	==1	&	t8	==1
replace vmt=	792	if	st42	==1	&	t8	==1
replace vmt=	6275	if	st43	==1	&	t8	==1
replace vmt=	20851	if	st44	==1	&	t8	==1
replace vmt=	2495	if	st45	==1	&	t8	==1
replace vmt=	735	if	st46	==1	&	t8	==1
replace vmt=	7343	if	st47	==1	&	t8	==1
replace vmt=	5316	if	st48	==1	&	t8	==1
replace vmt=	1845	if	st49	==1	&	t8	==1
replace vmt=	5560	if	st50	==1	&	t8	==1
replace vmt=	939	if	st51	==1	&	t8	==1
replace vmt=	4787	if	st1	==1	&	t9	==1
replace vmt=	414	if	st2 	==1	&	t9	==1
replace vmt=	4746	if	st3	==1	&	t9	==1
replace vmt=	2534	if	st4	==1	&	t9	==1
replace vmt=	23929	if	st5	==1	&	t9	==1
replace vmt=	3845	if	st6	==1	&	t9	==1
replace vmt=	2620	if	st7	==1	&	t9	==1
replace vmt=	818	if	st8	==1	&	t9	==1
replace vmt=	310	if	st9	==1	&	t9	==1
replace vmt=	15469	if	st10	==1	&	t9	==1
replace vmt=	8737	if	st11	==1	&	t9	==1
replace vmt=	1270	if	st12	==1	&	t9	==1
replace vmt=	1316	if	st13	==1	&	t9	==1
replace vmt=	8537	if	st14	==1	&	t9	==1
replace vmt=	5764	if	st15	==1	&	t9	==1
replace vmt=	2709	if	st16	==1	&	t9	==1
replace vmt=	2361	if	st17	==1	&	t9	==1
replace vmt=	3901	if	st18	==1	&	t9	==1
replace vmt=	3664	if	st19	==1	&	t9	==1
replace vmt=	1282	if	st20	==1	&	t9	==1
replace vmt=	4468	if	st21	==1	&	t9	==1
replace vmt=	4660	if	st22	==1	&	t9	==1
replace vmt=	8426	if	st23	==1	&	t9	==1
replace vmt=	4619	if	st24	==1	&	t9	==1
replace vmt=	3642	if	st25	==1	&	t9	==1
replace vmt=	6122	if	st26	==1	&	t9	==1
replace vmt=	369	if	st27	==1	&	t9	==1
replace vmt=	1659	if	st28	==1	&	t9	==1
replace vmt=	1742	if	st29	==1	&	t9	==1
replace vmt=	1247	if	st30	==1	&	t9	==1
replace vmt=	6442	if	st31	==1	&	t9	==1
replace vmt=	1969	if	st32	==1	&	t9	==1
replace vmt=	12079	if	st33	==1	&	t9	==1
replace vmt=	8120	if	st34	==1	&	t9	==1
replace vmt=	624	if	st35	==1	&	t9	==1
replace vmt=	8971	if	st36	==1	&	t9	==1
replace vmt=	3920	if	st37	==1	&	t9	==1
replace vmt=	3096	if	st38	==1	&	t9	==1
replace vmt=	8988	if	st39	==1	&	t9	==1
replace vmt=	981	if	st40	==1	&	t9	==1
replace vmt=	4254	if	st41	==1	&	t9	==1
replace vmt=	664	if	st42	==1	&	t9	==1
replace vmt=	5785	if	st43	==1	&	t9	==1
replace vmt=	19422	if	st44	==1	&	t9	==1
replace vmt=	2162	if	st45	==1	&	t9	==1
replace vmt=	625	if	st46	==1	&	t9	==1
replace vmt=	6656	if	st47	==1	&	t9	==1
replace vmt=	4875	if	st48	==1	&	t9	==1
replace vmt=	1832	if	st49	==1	&	t9	==1
replace vmt=	4964	if	st50	==1	&	t9	==1
replace vmt=	824	if	st51	==1	&	t9	==1
replace vmt=	4930	if	st1	==1	&	t10 	==1
replace vmt=	431	if	st2 	==1	&	t10 	==1
replace vmt=	4697	if	st3	==1	&	t10	==1
replace vmt=	2611	if	st4	==1	&	t10	==1
replace vmt=	28006	if	st5	==1	&	t10	==1
replace vmt=	3919	if	st6	==1	&	t10	==1
replace vmt=	2792	if	st7	==1	&	t10	==1
replace vmt=	806	if	st8	==1	&	t10	==1
replace vmt=	331	if	st9	==1	&	t10	==1
replace vmt=	16273	if	st10	==1	&	t10	==1
replace vmt=	9969	if	st11	==1	&	t10	==1
replace vmt=	913	if	st12	==1	&	t10	==1
replace vmt=	1355	if	st13	==1	&	t10	==1
replace vmt=	9548	if	st14	==1	&	t10	==1
replace vmt=	6182	if	st15	==1	&	t10	==1
replace vmt=	2850	if	st16	==1	&	t10	==1
replace vmt=	2541	if	st17	==1	&	t10	==1
replace vmt=	4176	if	st18	==1	&	t10	==1
replace vmt=	4039	if	st19	==1	&	t10	==1
replace vmt=	1252	if	st20	==1	&	t10	==1
replace vmt=	4989	if	st21	==1	&	t10	==1
replace vmt=	4959	if	st22	==1	&	t10	==1
replace vmt=	8600	if	st23	==1	&	t10	==1
replace vmt=	4909	if	st24	==1	&	t10	==1
replace vmt=	3236	if	st25	==1	&	t10	==1
replace vmt=	5798	if	st26	==1	&	t10	==1
replace vmt=	1045	if	st27	==1	&	t10	==1
replace vmt=	1724	if	st28	==1	&	t10	==1
replace vmt=	1750	if	st29	==1	&	t10	==1
replace vmt=	1073	if	st30	==1	&	t10	==1
replace vmt=	6537	if	st31	==1	&	t10	==1
replace vmt=	2095	if	st32	==1	&	t10	==1
replace vmt=	11815	if	st33	==1	&	t10	==1
replace vmt=	8925	if	st34	==1	&	t10	==1
replace vmt=	743	if	st35	==1	&	t10	==1
replace vmt=	9575	if	st36	==1	&	t10	==1
replace vmt=	4023	if	st37	==1	&	t10	==1
replace vmt=	2990	if	st38	==1	&	t10	==1
replace vmt=	9424	if	st39	==1	&	t10	==1
replace vmt=	597	if	st40	==1	&	t10	==1
replace vmt=	4159	if	st41	==1	&	t10	==1
replace vmt=	682	if	st42	==1	&	t10	==1
replace vmt=	6295	if	st43	==1	&	t10	==1
replace vmt=	20913	if	st44	==1	&	t10	==1
replace vmt=	2302	if	st45	==1	&	t10	==1
replace vmt=	628	if	st46	==1	&	t10	==1
replace vmt=	7004	if	st47	==1	&	t10	==1
replace vmt=	4840	if	st48	==1	&	t10	==1
replace vmt=	1863	if	st49	==1	&	t10	==1
replace vmt=	4990	if	st50	==1	&	t10	==1
replace vmt=	822	if	st51	==1	&	t10	==1
replace vmt=	4745	if	st1	==1	&	t11	==1
replace vmt=	364	if	st2 	==1	&	t11	==1
replace vmt=	5150	if	st3	==1	&	t11	==1
replace vmt=	2582	if	st4	==1	&	t11	==1
replace vmt=	30344	if	st5	==1	&	t11	==1
replace vmt=	3440	if	st6	==1	&	t11	==1
replace vmt=	2612	if	st7	==1	&	t11	==1
replace vmt=	744	if	st8	==1	&	t11	==1
replace vmt=	285	if	st9	==1	&	t11	==1
replace vmt=	15956	if	st10	==1	&	t11	==1
replace vmt=	8861	if	st11	==1	&	t11	==1
replace vmt=	915	if	st12	==1	&	t11	==1
replace vmt=	1220	if	st13	==1	&	t11	==1
replace vmt=	8323	if	st14	==1	&	t11	==1
replace vmt=	5577	if	st15	==1	&	t11	==1
replace vmt=	2584	if	st16	==1	&	t11	==1
replace vmt=	2547	if	st17	==1	&	t11	==1
replace vmt=	3875	if	st18	==1	&	t11	==1
replace vmt=	3794	if	st19	==1	&	t11	==1
replace vmt=	1145	if	st20	==1	&	t11	==1
replace vmt=	4590	if	st21	==1	&	t11	==1
replace vmt=	4519	if	st22	==1	&	t11	==1
replace vmt=	7875	if	st23	==1	&	t11	==1
replace vmt=	4736	if	st24	==1	&	t11	==1
replace vmt=	3487	if	st25	==1	&	t11	==1
replace vmt=	5486	if	st26	==1	&	t11	==1
replace vmt=	879	if	st27	==1	&	t11	==1
replace vmt=	1591	if	st28	==1	&	t11	==1
replace vmt=	1745	if	st29	==1	&	t11	==1
replace vmt=	1004	if	st30	==1	&	t11	==1
replace vmt=	6576	if	st31	==1	&	t11	==1
replace vmt=	1966	if	st32	==1	&	t11	==1
replace vmt=	10980	if	st33	==1	&	t11	==1
replace vmt=	8081	if	st34	==1	&	t11	==1
replace vmt=	624	if	st35	==1	&	t11	==1
replace vmt=	9376	if	st36	==1	&	t11	==1
replace vmt=	3924	if	st37	==1	&	t11	==1
replace vmt=	2757	if	st38	==1	&	t11	==1
replace vmt=	8510	if	st39	==1	&	t11	==1
replace vmt=	640	if	st40	==1	&	t11	==1
replace vmt=	3865	if	st41	==1	&	t11	==1
replace vmt=	687	if	st42	==1	&	t11	==1
replace vmt=	5301	if	st43	==1	&	t11	==1
replace vmt=	19620	if	st44	==1	&	t11	==1
replace vmt=	2145	if	st45	==1	&	t11	==1
replace vmt=	552	if	st46	==1	&	t11	==1
replace vmt=	6600	if	st47	==1	&	t11	==1
replace vmt=	4269	if	st48	==1	&	t11	==1
replace vmt=	1740	if	st49	==1	&	t11	==1
replace vmt=	4638	if	st50	==1	&	t11	==1
replace vmt=	726	if	st51	==1	&	t11	==1
replace vmt=	4603	if	st1	==1	&	t12	==1
replace vmt=	354	if	st2 	==1	&	t12	==1
replace vmt=	5241	if	st3	==1	&	t12	==1
replace vmt=	2742	if	st4	==1	&	t12	==1
replace vmt=	28525	if	st5	==1	&	t12	==1
replace vmt=	3564	if	st6	==1	&	t12	==1
replace vmt=	2520	if	st7	==1	&	t12	==1
replace vmt=	675	if	st8	==1	&	t12	==1
replace vmt=	274	if	st9	==1	&	t12	==1
replace vmt=	15804	if	st10	==1	&	t12	==1
replace vmt=	9196	if	st11	==1	&	t12	==1
replace vmt=	807	if	st12	==1	&	t12	==1
replace vmt=	1079	if	st13	==1	&	t12	==1
replace vmt=	7735	if	st14	==1	&	t12	==1
replace vmt=	5576	if	st15	==1	&	t12	==1
replace vmt=	2245	if	st16	==1	&	t12	==1
replace vmt=	2214	if	st17	==1	&	t12	==1
replace vmt=	3702	if	st18	==1	&	t12	==1
replace vmt=	3325	if	st19	==1	&	t12	==1
replace vmt=	1083	if	st20	==1	&	t12	==1
replace vmt=	4212	if	st21	==1	&	t12	==1
replace vmt=	4370	if	st22	==1	&	t12	==1
replace vmt=	7902	if	st23	==1	&	t12	==1
replace vmt=	4293	if	st24	==1	&	t12	==1
replace vmt=	2818	if	st25	==1	&	t12	==1
replace vmt=	5405	if	st26	==1	&	t12	==1
replace vmt=	907	if	st27	==1	&	t12	==1
replace vmt=	1419	if	st28	==1	&	t12	==1
replace vmt=	1747	if	st29	==1	&	t12	==1
replace vmt=	947	if	st30	==1	&	t12	==1
replace vmt=	6129	if	st31	==1	&	t12	==1
replace vmt=	2035	if	st32	==1	&	t12	==1
replace vmt=	10850	if	st33	==1	&	t12	==1
replace vmt=	8256	if	st34	==1	&	t12	==1
replace vmt=	616	if	st35	==1	&	t12	==1
replace vmt=	8792	if	st36	==1	&	t12	==1
replace vmt=	3552	if	st37	==1	&	t12	==1
replace vmt=	2606	if	st38	==1	&	t12	==1
replace vmt=	9473	if	st39	==1	&	t12	==1
replace vmt=	597	if	st40	==1	&	t12	==1
replace vmt=	3973	if	st41	==1	&	t12	==1
replace vmt=	693	if	st42	==1	&	t12	==1
replace vmt=	5670	if	st43	==1	&	t12	==1
replace vmt=	18726	if	st44	==1	&	t12	==1
replace vmt=	1936	if	st45	==1	&	t12	==1
replace vmt=	660	if	st46	==1	&	t12	==1
replace vmt=	6307	if	st47	==1	&	t12	==1
replace vmt=	3972	if	st48	==1	&	t12	==1
replace vmt=	1602	if	st49	==1	&	t12	==1
replace vmt=	4250	if	st50	==1	&	t12	==1
replace vmt=	677	if	st51	==1	&	t12	==1
replace vmt=	4537	if	st1	==1	&	t13	==1
replace vmt=	324	if	st2 	==1	&	t13	==1
replace vmt=	4992	if	st3	==1	&	t13	==1
replace vmt=	2509	if	st4	==1	&	t13	==1
replace vmt=	21493	if	st5	==1	&	t13	==1
replace vmt=	3860	if	st6	==1	&	t13	==1
replace vmt=	2453	if	st7	==1	&	t13	==1
replace vmt=	691	if	st8	==1	&	t13	==1
replace vmt=	281	if	st9	==1	&	t13	==1
replace vmt=	16961	if	st10	==1	&	t13	==1
replace vmt=	8817	if	st11	==1	&	t13	==1
replace vmt=	790	if	st12	==1	&	t13	==1
replace vmt=	1058	if	st13	==1	&	t13	==1
replace vmt=	7801	if	st14	==1	&	t13	==1
replace vmt=	5692	if	st15	==1	&	t13	==1
replace vmt=	2211	if	st16	==1	&	t13	==1
replace vmt=	2128	if	st17	==1	&	t13	==1
replace vmt=	3438	if	st18	==1	&	t13	==1
replace vmt=	3606	if	st19	==1	&	t13	==1
replace vmt=	1119	if	st20	==1	&	t13	==1
replace vmt=	4155	if	st21	==1	&	t13	==1
replace vmt=	4706	if	st22	==1	&	t13	==1
replace vmt=	8308	if	st23	==1	&	t13	==1
replace vmt=	4171	if	st24	==1	&	t13	==1
replace vmt=	3084	if	st25	==1	&	t13	==1
replace vmt=	5183	if	st26	==1	&	t13	==1
replace vmt=	817	if	st27	==1	&	t13	==1
replace vmt=	1378	if	st28	==1	&	t13	==1
replace vmt=	1535	if	st29	==1	&	t13	==1
replace vmt=	1022	if	st30	==1	&	t13	==1
replace vmt=	5456	if	st31	==1	&	t13	==1
replace vmt=	2182	if	st32	==1	&	t13	==1
replace vmt=	10710	if	st33	==1	&	t13	==1
replace vmt=	8019	if	st34	==1	&	t13	==1
replace vmt=	554	if	st35	==1	&	t13	==1
replace vmt=	8790	if	st36	==1	&	t13	==1
replace vmt=	3455	if	st37	==1	&	t13	==1
replace vmt=	2377	if	st38	==1	&	t13	==1
replace vmt=	7594	if	st39	==1	&	t13	==1
replace vmt=	442	if	st40	==1	&	t13	==1
replace vmt=	3880	if	st41	==1	&	t13	==1
replace vmt=	627	if	st42	==1	&	t13	==1
replace vmt=	5377	if	st43	==1	&	t13	==1
replace vmt=	19220	if	st44	==1	&	t13	==1
replace vmt=	1942	if	st45	==1	&	t13	==1
replace vmt=	693	if	st46	==1	&	t13	==1
replace vmt=	6113	if	st47	==1	&	t13	==1
replace vmt=	3745	if	st48	==1	&	t13	==1
replace vmt=	1464	if	st49	==1	&	t13	==1
replace vmt=	4304	if	st50	==1	&	t13	==1
replace vmt=	662	if	st51	==1	&	t13	==1
replace vmt=	4504	if	st1	==1	&	t14	==1
replace vmt=	316	if	st2 	==1	&	t14	==1
replace vmt=	5155	if	st3	==1	&	t14	==1
replace vmt=	2305	if	st4	==1	&	t14	==1
replace vmt=	22651	if	st5	==1	&	t14	==1
replace vmt=	3480	if	st6	==1	&	t14	==1
replace vmt=	2201	if	st7	==1	&	t14	==1
replace vmt=	640	if	st8	==1	&	t14	==1
replace vmt=	259	if	st9	==1	&	t14	==1
replace vmt=	15644	if	st10	==1	&	t14	==1
replace vmt=	8910	if	st11	==1	&	t14	==1
replace vmt=	614	if	st12	==1	&	t14	==1
replace vmt=	1037	if	st13	==1	&	t14	==1
replace vmt=	7433	if	st14	==1	&	t14	==1
replace vmt=	4929	if	st15	==1	&	t14	==1
replace vmt=	1991	if	st16	==1	&	t14	==1
replace vmt=	2093	if	st17	==1	&	t14	==1
replace vmt=	3199	if	st18	==1	&	t14	==1
replace vmt=	3349	if	st19	==1	&	t14	==1
replace vmt=	1035	if	st20	==1	&	t14	==1
replace vmt=	3794	if	st21	==1	&	t14	==1
replace vmt=	4078	if	st22	==1	&	t14	==1
replace vmt=	7216	if	st23	==1	&	t14	==1
replace vmt=	3891	if	st24	==1	&	t14	==1
replace vmt=	3033	if	st25	==1	&	t14	==1
replace vmt=	4531	if	st26	==1	&	t14	==1
replace vmt=	805	if	st27	==1	&	t14	==1
replace vmt=	1344	if	st28	==1	&	t14	==1
replace vmt=	1467	if	st29	==1	&	t14	==1
replace vmt=	958	if	st30	==1	&	t14	==1
replace vmt=	5128	if	st31	==1	&	t14	==1
replace vmt=	1972	if	st32	==1	&	t14	==1
replace vmt=	9865	if	st33	==1	&	t14	==1
replace vmt=	7600	if	st34	==1	&	t14	==1
replace vmt=	521	if	st35	==1	&	t14	==1
replace vmt=	7900	if	st36	==1	&	t14	==1
replace vmt=	3473	if	st37	==1	&	t14	==1
replace vmt=	2438	if	st38	==1	&	t14	==1
replace vmt=	7201	if	st39	==1	&	t14	==1
replace vmt=	575	if	st40	==1	&	t14	==1
replace vmt=	3812	if	st41	==1	&	t14	==1
replace vmt=	586	if	st42	==1	&	t14	==1
replace vmt=	5205	if	st43	==1	&	t14	==1
replace vmt=	18831	if	st44	==1	&	t14	==1
replace vmt=	1817	if	st45	==1	&	t14	==1
replace vmt=	602	if	st46	==1	&	t14	==1
replace vmt=	5789	if	st47	==1	&	t14	==1
replace vmt=	3645	if	st48	==1	&	t14	==1
replace vmt=	1182	if	st49	==1	&	t14	==1
replace vmt=	3980	if	st50	==1	&	t14	==1
replace vmt=	627	if	st51	==1	&	t14	==1
replace vmt=	5009	if	st1	==1	&	t15	==1
replace vmt=	382	if	st2 	==1	&	t15	==1
replace vmt=	5384	if	st3	==1	&	t15	==1
replace vmt=	2659	if	st4	==1	&	t15	==1
replace vmt=	26794	if	st5	==1	&	t15	==1
replace vmt=	4333	if	st6	==1	&	t15	==1
replace vmt=	2544	if	st7	==1	&	t15	==1
replace vmt=	716	if	st8	==1	&	t15	==1
replace vmt=	301	if	st9	==1	&	t15	==1
replace vmt=	17812	if	st10	==1	&	t15	==1
replace vmt=	9615	if	st11	==1	&	t15	==1
replace vmt=	765	if	st12	==1	&	t15	==1
replace vmt=	1188	if	st13	==1	&	t15	==1
replace vmt=	7964	if	st14	==1	&	t15	==1
replace vmt=	5637	if	st15	==1	&	t15	==1
replace vmt=	2415	if	st16	==1	&	t15	==1
replace vmt=	2498	if	st17	==1	&	t15	==1
replace vmt=	3695	if	st18	==1	&	t15	==1
replace vmt=	3706	if	st19	==1	&	t15	==1
replace vmt=	1170	if	st20	==1	&	t15	==1
replace vmt=	4577	if	st21	==1	&	t15	==1
replace vmt=	4293	if	st22	==1	&	t15	==1
replace vmt=	8230	if	st23	==1	&	t15	==1
replace vmt=	4436	if	st24	==1	&	t15	==1
replace vmt=	3421	if	st25	==1	&	t15	==1
replace vmt=	5350	if	st26	==1	&	t15	==1
replace vmt=	926	if	st27	==1	&	t15	==1
replace vmt=	1588	if	st28	==1	&	t15	==1
replace vmt=	1790	if	st29	==1	&	t15	==1
replace vmt=	1063	if	st30	==1	&	t15	==1
replace vmt=	6325	if	st31	==1	&	t15	==1
replace vmt=	2169	if	st32	==1	&	t15	==1
replace vmt=	11658	if	st33	==1	&	t15	==1
replace vmt=	8368	if	st34	==1	&	t15	==1
replace vmt=	624	if	st35	==1	&	t15	==1
replace vmt=	8644	if	st36	==1	&	t15	==1
replace vmt=	4063	if	st37	==1	&	t15	==1
replace vmt=	2875	if	st38	==1	&	t15	==1
replace vmt=	8314	if	st39	==1	&	t15	==1
replace vmt=	601	if	st40	==1	&	t15	==1
replace vmt=	4246	if	st41	==1	&	t15	==1
replace vmt=	683	if	st42	==1	&	t15	==1
replace vmt=	5662	if	st43	==1	&	t15	==1
replace vmt=	20759	if	st44	==1	&	t15	==1
replace vmt=	2250	if	st45	==1	&	t15	==1
replace vmt=	645	if	st46	==1	&	t15	==1
replace vmt=	6595	if	st47	==1	&	t15	==1
replace vmt=	4224	if	st48	==1	&	t15	==1
replace vmt=	1732	if	st49	==1	&	t15	==1
replace vmt=	4772	if	st50	==1	&	t15	==1
replace vmt=	708	if	st51	==1	&	t15	==1
replace vmt=	5087	if	st1	==1	&	t16	==1
replace vmt=	419	if	st2 	==1	&	t16	==1
replace vmt=	5248	if	st3	==1	&	t16	==1
replace vmt=	2427	if	st4	==1	&	t16	==1
replace vmt=	27355	if	st5	==1	&	t16	==1
replace vmt=	4033	if	st6	==1	&	t16	==1
replace vmt=	2480	if	st7	==1	&	t16	==1
replace vmt=	748	if	st8	==1	&	t16	==1
replace vmt=	328	if	st9	==1	&	t16	==1
replace vmt=	16486	if	st10	==1	&	t16	==1
replace vmt=	9737	if	st11	==1	&	t16	==1
replace vmt=	812	if	st12	==1	&	t16	==1
replace vmt=	1196	if	st13	==1	&	t16	==1
replace vmt=	8675	if	st14	==1	&	t16	==1
replace vmt=	5966	if	st15	==1	&	t16	==1
replace vmt=	2518	if	st16	==1	&	t16	==1
replace vmt=	2426	if	st17	==1	&	t16	==1
replace vmt=	3923	if	st18	==1	&	t16	==1
replace vmt=	3851	if	st19	==1	&	t16	==1
replace vmt=	1156	if	st20	==1	&	t16	==1
replace vmt=	4569	if	st21	==1	&	t16	==1
replace vmt=	4086	if	st22	==1	&	t16	==1
replace vmt=	8265	if	st23	==1	&	t16	==1
replace vmt=	4384	if	st24	==1	&	t16	==1
replace vmt=	3535	if	st25	==1	&	t16	==1
replace vmt=	5474	if	st26	==1	&	t16	==1
replace vmt=	901	if	st27	==1	&	t16	==1
replace vmt=	1581	if	st28	==1	&	t16	==1
replace vmt=	1783	if	st29	==1	&	t16	==1
replace vmt=	1101	if	st30	==1	&	t16	==1
replace vmt=	6174	if	st31	==1	&	t16	==1
replace vmt=	1896	if	st32	==1	&	t16	==1
replace vmt=	11405	if	st33	==1	&	t16	==1
replace vmt=	8317	if	st34	==1	&	t16	==1
replace vmt=	662	if	st35	==1	&	t16	==1
replace vmt=	8893	if	st36	==1	&	t16	==1
replace vmt=	4046	if	st37	==1	&	t16	==1
replace vmt=	2763	if	st38	==1	&	t16	==1
replace vmt=	8831	if	st39	==1	&	t16	==1
replace vmt=	635	if	st40	==1	&	t16	==1
replace vmt=	4183	if	st41	==1	&	t16	==1
replace vmt=	683	if	st42	==1	&	t16	==1
replace vmt=	5787	if	st43	==1	&	t16	==1
replace vmt=	19755	if	st44	==1	&	t16	==1
replace vmt=	2193	if	st45	==1	&	t16	==1
replace vmt=	530	if	st46	==1	&	t16	==1
replace vmt=	6538	if	st47	==1	&	t16	==1
replace vmt=	4719	if	st48	==1	&	t16	==1
replace vmt=	1661	if	st49	==1	&	t16	==1
replace vmt=	4772	if	st50	==1	&	t16	==1
replace vmt=	747	if	st51	==1	&	t16	==1
replace vmt=	5074	if	st1	==1	&	t17	==1
replace vmt=	481	if	st2 	==1	&	t17	==1
replace vmt=	5354	if	st3	==1	&	t17	==1
replace vmt=	2740	if	st4	==1	&	t17	==1
replace vmt=	27238	if	st5	==1	&	t17	==1
replace vmt=	3957	if	st6	==1	&	t17	==1
replace vmt=	2783	if	st7	==1	&	t17	==1
replace vmt=	799	if	st8	==1	&	t17	==1
replace vmt=	340	if	st9	==1	&	t17	==1
replace vmt=	16593	if	st10	==1	&	t17	==1
replace vmt=	9843	if	st11	==1	&	t17	==1
replace vmt=	639	if	st12	==1	&	t17	==1
replace vmt=	1287	if	st13	==1	&	t17	==1
replace vmt=	8948	if	st14	==1	&	t17	==1
replace vmt=	5946	if	st15	==1	&	t17	==1
replace vmt=	2753	if	st16	==1	&	t17	==1
replace vmt=	2478	if	st17	==1	&	t17	==1
replace vmt=	4083	if	st18	==1	&	t17	==1
replace vmt=	3851	if	st19	==1	&	t17	==1
replace vmt=	1254	if	st20	==1	&	t17	==1
replace vmt=	4926	if	st21	==1	&	t17	==1
replace vmt=	4525	if	st22	==1	&	t17	==1
replace vmt=	8527	if	st23	==1	&	t17	==1
replace vmt=	4902	if	st24	==1	&	t17	==1
replace vmt=	3524	if	st25	==1	&	t17	==1
replace vmt=	5997	if	st26	==1	&	t17	==1
replace vmt=	970	if	st27	==1	&	t17	==1
replace vmt=	1694	if	st28	==1	&	t17	==1
replace vmt=	1922	if	st29	==1	&	t17	==1
replace vmt=	1090	if	st30	==1	&	t17	==1
replace vmt=	6085	if	st31	==1	&	t17	==1
replace vmt=	2012	if	st32	==1	&	t17	==1
replace vmt=	12050	if	st33	==1	&	t17	==1
replace vmt=	8513	if	st34	==1	&	t17	==1
replace vmt=	684	if	st35	==1	&	t17	==1
replace vmt=	9281	if	st36	==1	&	t17	==1
replace vmt=	4391	if	st37	==1	&	t17	==1
replace vmt=	3074	if	st38	==1	&	t17	==1
replace vmt=	8926	if	st39	==1	&	t17	==1
replace vmt=	722	if	st40	==1	&	t17	==1
replace vmt=	4373	if	st41	==1	&	t17	==1
replace vmt=	795	if	st42	==1	&	t17	==1
replace vmt=	5835	if	st43	==1	&	t17	==1
replace vmt=	20309	if	st44	==1	&	t17	==1
replace vmt=	2133	if	st45	==1	&	t17	==1
replace vmt=	616	if	st46	==1	&	t17	==1
replace vmt=	6945	if	st47	==1	&	t17	==1
replace vmt=	5131	if	st48	==1	&	t17	==1
replace vmt=	1724	if	st49	==1	&	t17	==1
replace vmt=	5167	if	st50	==1	&	t17	==1
replace vmt=	817	if	st51	==1	&	t17	==1
replace vmt=	4945	if	st1	==1	&	t18	==1
replace vmt=	447	if	st2 	==1	&	t18	==1
replace vmt=	5419	if	st3	==1	&	t18	==1
replace vmt=	2684	if	st4	==1	&	t18	==1
replace vmt=	28772	if	st5	==1	&	t18	==1
replace vmt=	3663	if	st6	==1	&	t18	==1
replace vmt=	2644	if	st7	==1	&	t18	==1
replace vmt=	847	if	st8	==1	&	t18	==1
replace vmt=	333	if	st9	==1	&	t18	==1
replace vmt=	15762	if	st10	==1	&	t18	==1
replace vmt=	8927	if	st11	==1	&	t18	==1
replace vmt=	788	if	st12	==1	&	t18	==1
replace vmt=	1283	if	st13	==1	&	t18	==1
replace vmt=	9495	if	st14	==1	&	t18	==1
replace vmt=	5819	if	st15	==1	&	t18	==1
replace vmt=	2681	if	st16	==1	&	t18	==1
replace vmt=	2403	if	st17	==1	&	t18	==1
replace vmt=	3924	if	st18	==1	&	t18	==1
replace vmt=	3927	if	st19	==1	&	t18	==1
replace vmt=	1241	if	st20	==1	&	t18	==1
replace vmt=	4827	if	st21	==1	&	t18	==1
replace vmt=	4612	if	st22	==1	&	t18	==1
replace vmt=	8529	if	st23	==1	&	t18	==1
replace vmt=	4904	if	st24	==1	&	t18	==1
replace vmt=	3379	if	st25	==1	&	t18	==1
replace vmt=	5741	if	st26	==1	&	t18	==1
replace vmt=	1077	if	st27	==1	&	t18	==1
replace vmt=	1677	if	st28	==1	&	t18	==1
replace vmt=	1651	if	st29	==1	&	t18	==1
replace vmt=	1140	if	st30	==1	&	t18	==1
replace vmt=	6111	if	st31	==1	&	t18	==1
replace vmt=	1872	if	st32	==1	&	t18	==1
replace vmt=	11635	if	st33	==1	&	t18	==1
replace vmt=	8381	if	st34	==1	&	t18	==1
replace vmt=	686	if	st35	==1	&	t18	==1
replace vmt=	9234	if	st36	==1	&	t18	==1
replace vmt=	3995	if	st37	==1	&	t18	==1
replace vmt=	2971	if	st38	==1	&	t18	==1
replace vmt=	9122	if	st39	==1	&	t18	==1
replace vmt=	702	if	st40	==1	&	t18	==1
replace vmt=	4153	if	st41	==1	&	t18	==1
replace vmt=	863	if	st42	==1	&	t18	==1
replace vmt=	5846	if	st43	==1	&	t18	==1
replace vmt=	19216	if	st44	==1	&	t18	==1
replace vmt=	2056	if	st45	==1	&	t18	==1
replace vmt=	592	if	st46	==1	&	t18	==1
replace vmt=	6707	if	st47	==1	&	t18	==1
replace vmt=	4769	if	st48	==1	&	t18	==1
replace vmt=	1699	if	st49	==1	&	t18	==1
replace vmt=	5025	if	st50	==1	&	t18	==1
replace vmt=	843	if	st51	==1	&	t18	==1
replace vmt=	4956	if	st1	==1	&	t19	==1
replace vmt=	466	if	st2 	==1	&	t19	==1
replace vmt=	4753	if	st3	==1	&	t19	==1
replace vmt=	2852	if	st4	==1	&	t19	==1
replace vmt=	27939	if	st5	==1	&	t19	==1
replace vmt=	3792	if	st6	==1	&	t19	==1
replace vmt=	2764	if	st7	==1	&	t19	==1
replace vmt=	887	if	st8	==1	&	t19	==1
replace vmt=	367	if	st9	==1	&	t19	==1
replace vmt=	16061	if	st10	==1	&	t19	==1
replace vmt=	9106	if	st11	==1	&	t19	==1
replace vmt=	830	if	st12	==1	&	t19	==1
replace vmt=	1380	if	st13	==1	&	t19	==1
replace vmt=	8757	if	st14	==1	&	t19	==1
replace vmt=	6133	if	st15	==1	&	t19	==1
replace vmt=	2716	if	st16	==1	&	t19	==1
replace vmt=	2543	if	st17	==1	&	t19	==1
replace vmt=	3993	if	st18	==1	&	t19	==1
replace vmt=	3871	if	st19	==1	&	t19	==1
replace vmt=	1332	if	st20	==1	&	t19	==1
replace vmt=	4775	if	st21	==1	&	t19	==1
replace vmt=	4925	if	st22	==1	&	t19	==1
replace vmt=	8658	if	st23	==1	&	t19	==1
replace vmt=	4697	if	st24	==1	&	t19	==1
replace vmt=	3471	if	st25	==1	&	t19	==1
replace vmt=	6070	if	st26	==1	&	t19	==1
replace vmt=	1148	if	st27	==1	&	t19	==1
replace vmt=	1754	if	st28	==1	&	t19	==1
replace vmt=	1759	if	st29	==1	&	t19	==1
replace vmt=	1202	if	st30	==1	&	t19	==1
replace vmt=	5959	if	st31	==1	&	t19	==1
replace vmt=	2057	if	st32	==1	&	t19	==1
replace vmt=	11941	if	st33	==1	&	t19	==1
replace vmt=	8526	if	st34	==1	&	t19	==1
replace vmt=	811	if	st35	==1	&	t19	==1
replace vmt=	9558	if	st36	==1	&	t19	==1
replace vmt=	4259	if	st37	==1	&	t19	==1
replace vmt=	3209	if	st38	==1	&	t19	==1
replace vmt=	9621	if	st39	==1	&	t19	==1
replace vmt=	780	if	st40	==1	&	t19	==1
replace vmt=	4272	if	st41	==1	&	t19	==1
replace vmt=	891	if	st42	==1	&	t19	==1
replace vmt=	6098	if	st43	==1	&	t19	==1
replace vmt=	19605	if	st44	==1	&	t19	==1
replace vmt=	2224	if	st45	==1	&	t19	==1
replace vmt=	709	if	st46	==1	&	t19	==1
replace vmt=	6973	if	st47	==1	&	t19	==1
replace vmt=	5149	if	st48	==1	&	t19	==1
replace vmt=	1716	if	st49	==1	&	t19	==1
replace vmt=	5302	if	st50	==1	&	t19	==1
replace vmt=	923	if	st51	==1	&	t19	==1
replace vmt=	4988	if	st1	==1	&	t20	==1
replace vmt=	459	if	st2 	==1	&	t20	==1
replace vmt=	4299	if	st3	==1	&	t20	==1
replace vmt=	2713	if	st4	==1	&	t20	==1
replace vmt=	28151	if	st5	==1	&	t20	==1
replace vmt=	4126	if	st6	==1	&	t20	==1
replace vmt=	2747	if	st7	==1	&	t20	==1
replace vmt=	875	if	st8	==1	&	t20	==1
replace vmt=	338	if	st9	==1	&	t20	==1
replace vmt=	15667	if	st10	==1	&	t20	==1
replace vmt=	8935	if	st11	==1	&	t20	==1
replace vmt=	787	if	st12	==1	&	t20	==1
replace vmt=	1399	if	st13	==1	&	t20	==1
replace vmt=	8537	if	st14	==1	&	t20	==1
replace vmt=	5606	if	st15	==1	&	t20	==1
replace vmt=	2730	if	st16	==1	&	t20	==1
replace vmt=	2511	if	st17	==1	&	t20	==1
replace vmt=	3971	if	st18	==1	&	t20	==1
replace vmt=	4078	if	st19	==1	&	t20	==1
replace vmt=	1266	if	st20	==1	&	t20	==1
replace vmt=	5018	if	st21	==1	&	t20	==1
replace vmt=	4671	if	st22	==1	&	t20	==1
replace vmt=	8664	if	st23	==1	&	t20	==1
replace vmt=	4909	if	st24	==1	&	t20	==1
replace vmt=	3282	if	st25	==1	&	t20	==1
replace vmt=	6160	if	st26	==1	&	t20	==1
replace vmt=	1130	if	st27	==1	&	t20	==1
replace vmt=	1734	if	st28	==1	&	t20	==1
replace vmt=	1746	if	st29	==1	&	t20	==1
replace vmt=	1231	if	st30	==1	&	t20	==1
replace vmt=	5936	if	st31	==1	&	t20	==1
replace vmt=	2000	if	st32	==1	&	t20	==1
replace vmt=	12511	if	st33	==1	&	t20	==1
replace vmt=	8361	if	st34	==1	&	t20	==1
replace vmt=	753	if	st35	==1	&	t20	==1
replace vmt=	9126	if	st36	==1	&	t20	==1
replace vmt=	4425	if	st37	==1	&	t20	==1
replace vmt=	3276	if	st38	==1	&	t20	==1
replace vmt=	9816	if	st39	==1	&	t20	==1
replace vmt=	819	if	st40	==1	&	t20	==1
replace vmt=	4142	if	st41	==1	&	t20	==1
replace vmt=	866	if	st42	==1	&	t20	==1
replace vmt=	5748	if	st43	==1	&	t20	==1
replace vmt=	19927	if	st44	==1	&	t20	==1
replace vmt=	2325	if	st45	==1	&	t20	==1
replace vmt=	725	if	st46	==1	&	t20	==1
replace vmt=	6957	if	st47	==1	&	t20	==1
replace vmt=	5198	if	st48	==1	&	t20	==1
replace vmt=	1753	if	st49	==1	&	t20	==1
replace vmt=	5365	if	st50	==1	&	t20	==1
replace vmt=	935	if	st51	==1	&	t20	==1
replace vmt=	4453	if	st1	==1	&	t21	==1
replace vmt=	408	if	st2 	==1	&	t21	==1
replace vmt=	4167	if	st3	==1	&	t21	==1
replace vmt=	2350	if	st4	==1	&	t21	==1
replace vmt=	23019	if	st5	==1	&	t21	==1
replace vmt=	3702	if	st6	==1	&	t21	==1
replace vmt=	2520	if	st7	==1	&	t21	==1
replace vmt=	803	if	st8	==1	&	t21	==1
replace vmt=	322	if	st9	==1	&	t21	==1
replace vmt=	15103	if	st10	==1	&	t21	==1
replace vmt=	8249	if	st11	==1	&	t21	==1
replace vmt=	1007	if	st12	==1	&	t21	==1
replace vmt=	1255	if	st13	==1	&	t21	==1
replace vmt=	7978	if	st14	==1	&	t21	==1
replace vmt=	5516	if	st15	==1	&	t21	==1
replace vmt=	2606	if	st16	==1	&	t21	==1
replace vmt=	2283	if	st17	==1	&	t21	==1
replace vmt=	3650	if	st18	==1	&	t21	==1
replace vmt=	3373	if	st19	==1	&	t21	==1
replace vmt=	1131	if	st20	==1	&	t21	==1
replace vmt=	4173	if	st21	==1	&	t21	==1
replace vmt=	4238	if	st22	==1	&	t21	==1
replace vmt=	7945	if	st23	==1	&	t21	==1
replace vmt=	4504	if	st24	==1	&	t21	==1
replace vmt=	3054	if	st25	==1	&	t21	==1
replace vmt=	6009	if	st26	==1	&	t21	==1
replace vmt=	892	if	st27	==1	&	t21	==1
replace vmt=	1600	if	st28	==1	&	t21	==1
replace vmt=	1663	if	st29	==1	&	t21	==1
replace vmt=	1059	if	st30	==1	&	t21	==1
replace vmt=	6145	if	st31	==1	&	t21	==1
replace vmt=	1899	if	st32	==1	&	t21	==1
replace vmt=	11533	if	st33	==1	&	t21	==1
replace vmt=	7803	if	st34	==1	&	t21	==1
replace vmt=	641	if	st35	==1	&	t21	==1
replace vmt=	8705	if	st36	==1	&	t21	==1
replace vmt=	3874	if	st37	==1	&	t21	==1
replace vmt=	2922	if	st38	==1	&	t21	==1
replace vmt=	8917	if	st39	==1	&	t21	==1
replace vmt=	987	if	st40	==1	&	t21	==1
replace vmt=	3756	if	st41	==1	&	t21	==1
replace vmt=	733	if	st42	==1	&	t21	==1
replace vmt=	5364	if	st43	==1	&	t21	==1
replace vmt=	18838	if	st44	==1	&	t21	==1
replace vmt=	2028	if	st45	==1	&	t21	==1
replace vmt=	596	if	st46	==1	&	t21	==1
replace vmt=	6267	if	st47	==1	&	t21	==1
replace vmt=	4795	if	st48	==1	&	t21	==1
replace vmt=	1702	if	st49	==1	&	t21	==1
replace vmt=	4750	if	st50	==1	&	t21	==1
replace vmt=	838	if	st51	==1	&	t21	==1
replace vmt=	4657	if	st1	==1	&	t22	==1
replace vmt=	413	if	st2 	==1	&	t22	==1
replace vmt=	4597	if	st3	==1	&	t22	==1
replace vmt=	2603	if	st4	==1	&	t22	==1
replace vmt=	27743	if	st5	==1	&	t22	==1
replace vmt=	3915	if	st6	==1	&	t22	==1
replace vmt=	2769	if	st7	==1	&	t22	==1
replace vmt=	775	if	st8	==1	&	t22	==1
replace vmt=	320	if	st9	==1	&	t22	==1
replace vmt=	16158	if	st10	==1	&	t22	==1
replace vmt=	9360	if	st11	==1	&	t22	==1
replace vmt=	1101	if	st12	==1	&	t22	==1
replace vmt=	1257	if	st13	==1	&	t22	==1
replace vmt=	8891	if	st14	==1	&	t22	==1
replace vmt=	6130	if	st15	==1	&	t22	==1
replace vmt=	2772	if	st16	==1	&	t22	==1
replace vmt=	2398	if	st17	==1	&	t22	==1
replace vmt=	4016	if	st18	==1	&	t22	==1
replace vmt=	3884	if	st19	==1	&	t22	==1
replace vmt=	1215	if	st20	==1	&	t22	==1
replace vmt=	4855	if	st21	==1	&	t22	==1
replace vmt=	4679	if	st22	==1	&	t22	==1
replace vmt=	8447	if	st23	==1	&	t22	==1
replace vmt=	4783	if	st24	==1	&	t22	==1
replace vmt=	3349	if	st25	==1	&	t22	==1
replace vmt=	5540	if	st26	==1	&	t22	==1
replace vmt=	841	if	st27	==1	&	t22	==1
replace vmt=	1706	if	st28	==1	&	t22	==1
replace vmt=	1750	if	st29	==1	&	t22	==1
replace vmt=	1146	if	st30	==1	&	t22	==1
replace vmt=	6207	if	st31	==1	&	t22	==1
replace vmt=	2105	if	st32	==1	&	t22	==1
replace vmt=	11619	if	st33	==1	&	t22	==1
replace vmt=	8624	if	st34	==1	&	t22	==1
replace vmt=	731	if	st35	==1	&	t22	==1
replace vmt=	9278	if	st36	==1	&	t22	==1
replace vmt=	3962	if	st37	==1	&	t22	==1
replace vmt=	2894	if	st38	==1	&	t22	==1
replace vmt=	9386	if	st39	==1	&	t22	==1
replace vmt=	581	if	st40	==1	&	t22	==1
replace vmt=	3918	if	st41	==1	&	t22	==1
replace vmt=	744	if	st42	==1	&	t22	==1
replace vmt=	5758	if	st43	==1	&	t22	==1
replace vmt=	20377	if	st44	==1	&	t22	==1
replace vmt=	2051	if	st45	==1	&	t22	==1
replace vmt=	626	if	st46	==1	&	t22	==1
replace vmt=	6710	if	st47	==1	&	t22	==1
replace vmt=	4666	if	st48	==1	&	t22	==1
replace vmt=	1762	if	st49	==1	&	t22	==1
replace vmt=	4859	if	st50	==1	&	t22	==1
replace vmt=	810	if	st51	==1	&	t22	==1
replace vmt=	4492	if	st1	==1	&	t23	==1
replace vmt=	351	if	st2 	==1	&	t23	==1
replace vmt=	4603	if	st3	==1	&	t23	==1
replace vmt=	2453	if	st4	==1	&	t23	==1
replace vmt=	28216	if	st5	==1	&	t23	==1
replace vmt=	3445	if	st6	==1	&	t23	==1
replace vmt=	2551	if	st7	==1	&	t23	==1
replace vmt=	687	if	st8	==1	&	t23	==1
replace vmt=	270	if	st9	==1	&	t23	==1
replace vmt=	15753	if	st10	==1	&	t23	==1
replace vmt=	8229	if	st11	==1	&	t23	==1
replace vmt=	903	if	st12	==1	&	t23	==1
replace vmt=	1156	if	st13	==1	&	t23	==1
replace vmt=	7615	if	st14	==1	&	t23	==1
replace vmt=	5337	if	st15	==1	&	t23	==1
replace vmt=	2416	if	st16	==1	&	t23	==1
replace vmt=	2425	if	st17	==1	&	t23	==1
replace vmt=	3720	if	st18	==1	&	t23	==1
replace vmt=	3656	if	st19	==1	&	t23	==1
replace vmt=	1112	if	st20	==1	&	t23	==1
replace vmt=	4388	if	st21	==1	&	t23	==1
replace vmt=	4243	if	st22	==1	&	t23	==1
replace vmt=	7521	if	st23	==1	&	t23	==1
replace vmt=	4569	if	st24	==1	&	t23	==1
replace vmt=	3307	if	st25	==1	&	t23	==1
replace vmt=	5335	if	st26	==1	&	t23	==1
replace vmt=	854	if	st27	==1	&	t23	==1
replace vmt=	1546	if	st28	==1	&	t23	==1
replace vmt=	1686	if	st29	==1	&	t23	==1
replace vmt=	975	if	st30	==1	&	t23	==1
replace vmt=	6027	if	st31	==1	&	t23	==1
replace vmt=	2034	if	st32	==1	&	t23	==1
replace vmt=	10010	if	st33	==1	&	t23	==1
replace vmt=	7634	if	st34	==1	&	t23	==1
replace vmt=	595	if	st35	==1	&	t23	==1
replace vmt=	8691	if	st36	==1	&	t23	==1
replace vmt=	3861	if	st37	==1	&	t23	==1
replace vmt=	2552	if	st38	==1	&	t23	==1
replace vmt=	8451	if	st39	==1	&	t23	==1
replace vmt=	590	if	st40	==1	&	t23	==1
replace vmt=	3684	if	st41	==1	&	t23	==1
replace vmt=	650	if	st42	==1	&	t23	==1
replace vmt=	5032	if	st43	==1	&	t23	==1
replace vmt=	19357	if	st44	==1	&	t23	==1
replace vmt=	1951	if	st45	==1	&	t23	==1
replace vmt=	519	if	st46	==1	&	t23	==1
replace vmt=	6290	if	st47	==1	&	t23	==1
replace vmt=	4140	if	st48	==1	&	t23	==1
replace vmt=	1593	if	st49	==1	&	t23	==1
replace vmt=	4438	if	st50	==1	&	t23	==1
replace vmt=	683	if	st51	==1	&	t23	==1
replace vmt=	4644	if	st1	==1	&	t24	==1
replace vmt=	359	if	st2 	==1	&	t24	==1
replace vmt=	5401	if	st3	==1	&	t24	==1
replace vmt=	2714	if	st4	==1	&	t24	==1
replace vmt=	26982	if	st5	==1	&	t24	==1
replace vmt=	3814	if	st6	==1	&	t24	==1
replace vmt=	2538	if	st7	==1	&	t24	==1
replace vmt=	693	if	st8	==1	&	t24	==1
replace vmt=	278	if	st9	==1	&	t24	==1
replace vmt=	16500	if	st10	==1	&	t24	==1
replace vmt=	9127	if	st11	==1	&	t24	==1
replace vmt=	845	if	st12	==1	&	t24	==1
replace vmt=	1067	if	st13	==1	&	t24	==1
replace vmt=	7818	if	st14	==1	&	t24	==1
replace vmt=	5595	if	st15	==1	&	t24	==1
replace vmt=	2255	if	st16	==1	&	t24	==1
replace vmt=	2459	if	st17	==1	&	t24	==1
replace vmt=	3701	if	st18	==1	&	t24	==1
replace vmt=	3460	if	st19	==1	&	t24	==1
replace vmt=	1120	if	st20	==1	&	t24	==1
replace vmt=	4323	if	st21	==1	&	t24	==1
replace vmt=	4527	if	st22	==1	&	t24	==1
replace vmt=	7839	if	st23	==1	&	t24	==1
replace vmt=	4285	if	st24	==1	&	t24	==1
replace vmt=	3038	if	st25	==1	&	t24	==1
replace vmt=	5571	if	st26	==1	&	t24	==1
replace vmt=	766	if	st27	==1	&	t24	==1
replace vmt=	1491	if	st28	==1	&	t24	==1
replace vmt=	1757	if	st29	==1	&	t24	==1
replace vmt=	1036	if	st30	==1	&	t24	==1
replace vmt=	6287	if	st31	==1	&	t24	==1
replace vmt=	2205	if	st32	==1	&	t24	==1
replace vmt=	10853	if	st33	==1	&	t24	==1
replace vmt=	7986	if	st34	==1	&	t24	==1
replace vmt=	593	if	st35	==1	&	t24	==1
replace vmt=	8718	if	st36	==1	&	t24	==1
replace vmt=	3340	if	st37	==1	&	t24	==1
replace vmt=	2227	if	st38	==1	&	t24	==1
replace vmt=	9832	if	st39	==1	&	t24	==1
replace vmt=	647	if	st40	==1	&	t24	==1
replace vmt=	3897	if	st41	==1	&	t24	==1
replace vmt=	655	if	st42	==1	&	t24	==1
replace vmt=	5536	if	st43	==1	&	t24	==1
replace vmt=	19130	if	st44	==1	&	t24	==1
replace vmt=	1932	if	st45	==1	&	t24	==1
replace vmt=	549	if	st46	==1	&	t24	==1
replace vmt=	6431	if	st47	==1	&	t24	==1
replace vmt=	3649	if	st48	==1	&	t24	==1
replace vmt=	1603	if	st49	==1	&	t24	==1
replace vmt=	4234	if	st50	==1	&	t24	==1
replace vmt=	677	if	st51	==1	&	t24	==1
replace vmt=	4553	if	st1	==1	&	t25	==1
replace vmt=	323	if	st2 	==1	&	t25	==1
replace vmt=	4976	if	st3	==1	&	t25	==1
replace vmt=	2805	if	st4	==1	&	t25	==1
replace vmt=	21853	if	st5	==1	&	t25	==1
replace vmt=	3997	if	st6	==1	&	t25	==1
replace vmt=	2322	if	st7	==1	&	t25	==1
replace vmt=	679	if	st8	==1	&	t25	==1
replace vmt=	281	if	st9	==1	&	t25	==1
replace vmt=	16430	if	st10	==1	&	t25	==1
replace vmt=	8875	if	st11	==1	&	t25	==1
replace vmt=	827	if	st12	==1	&	t25	==1
replace vmt=	1075	if	st13	==1	&	t25	==1
replace vmt=	7280	if	st14	==1	&	t25	==1
replace vmt=	5226	if	st15	==1	&	t25	==1
replace vmt=	2151	if	st16	==1	&	t25	==1
replace vmt=	2200	if	st17	==1	&	t25	==1
replace vmt=	3266	if	st18	==1	&	t25	==1
replace vmt=	4042	if	st19	==1	&	t25	==1
replace vmt=	1098	if	st20	==1	&	t25	==1
replace vmt=	4012	if	st21	==1	&	t25	==1
replace vmt=	4459	if	st22	==1	&	t25	==1
replace vmt=	8013	if	st23	==1	&	t25	==1
replace vmt=	4018	if	st24	==1	&	t25	==1
replace vmt=	3249	if	st25	==1	&	t25	==1
replace vmt=	5056	if	st26	==1	&	t25	==1
replace vmt=	638	if	st27	==1	&	t25	==1
replace vmt=	1364	if	st28	==1	&	t25	==1
replace vmt=	1599	if	st29	==1	&	t25	==1
replace vmt=	970	if	st30	==1	&	t25	==1
replace vmt=	5016	if	st31	==1	&	t25	==1
replace vmt=	2194	if	st32	==1	&	t25	==1
replace vmt=	9960	if	st33	==1	&	t25	==1
replace vmt=	7907	if	st34	==1	&	t25	==1
replace vmt=	550	if	st35	==1	&	t25	==1
replace vmt=	7891	if	st36	==1	&	t25	==1
replace vmt=	3616	if	st37	==1	&	t25	==1
replace vmt=	2440	if	st38	==1	&	t25	==1
replace vmt=	7398	if	st39	==1	&	t25	==1
replace vmt=	437	if	st40	==1	&	t25	==1
replace vmt=	3823	if	st41	==1	&	t25	==1
replace vmt=	600	if	st42	==1	&	t25	==1
replace vmt=	5313	if	st43	==1	&	t25	==1
replace vmt=	19314	if	st44	==1	&	t25	==1
replace vmt=	1924	if	st45	==1	&	t25	==1
replace vmt=	652	if	st46	==1	&	t25	==1
replace vmt=	5975	if	st47	==1	&	t25	==1
replace vmt=	3917	if	st48	==1	&	t25	==1
replace vmt=	1346	if	st49	==1	&	t25	==1
replace vmt=	4227	if	st50	==1	&	t25	==1
replace vmt=	637	if	st51	==1	&	t25	==1
replace vmt=	4463	if	st1	==1	&	t26	==1
replace vmt=	322	if	st2 	==1	&	t26	==1
replace vmt=	4963	if	st3	==1	&	t26	==1
replace vmt=	2467	if	st4	==1	&	t26	==1
replace vmt=	21805	if	st5	==1	&	t26	==1
replace vmt=	3634	if	st6	==1	&	t26	==1
replace vmt=	2258	if	st7	==1	&	t26	==1
replace vmt=	639	if	st8	==1	&	t26	==1
replace vmt=	306	if	st9	==1	&	t26	==1
replace vmt=	15092	if	st10	==1	&	t26	==1
replace vmt=	8337	if	st11	==1	&	t26	==1
replace vmt=	707	if	st12	==1	&	t26	==1
replace vmt=	1063	if	st13	==1	&	t26	==1
replace vmt=	7741	if	st14	==1	&	t26	==1
replace vmt=	4942	if	st15	==1	&	t26	==1
replace vmt=	2125	if	st16	==1	&	t26	==1
replace vmt=	2269	if	st17	==1	&	t26	==1
replace vmt=	3315	if	st18	==1	&	t26	==1
replace vmt=	3415	if	st19	==1	&	t26	==1
replace vmt=	1072	if	st20	==1	&	t26	==1
replace vmt=	3877	if	st21	==1	&	t26	==1
replace vmt=	4246	if	st22	==1	&	t26	==1
replace vmt=	7358	if	st23	==1	&	t26	==1
replace vmt=	3828	if	st24	==1	&	t26	==1
replace vmt=	3172	if	st25	==1	&	t26	==1
replace vmt=	4716	if	st26	==1	&	t26	==1
replace vmt=	668	if	st27	==1	&	t26	==1
replace vmt=	1339	if	st28	==1	&	t26	==1
replace vmt=	1450	if	st29	==1	&	t26	==1
replace vmt=	963	if	st30	==1	&	t26	==1
replace vmt=	5254	if	st31	==1	&	t26	==1
replace vmt=	1987	if	st32	==1	&	t26	==1
replace vmt=	9834	if	st33	==1	&	t26	==1
replace vmt=	7497	if	st34	==1	&	t26	==1
replace vmt=	530	if	st35	==1	&	t26	==1
replace vmt=	7912	if	st36	==1	&	t26	==1
replace vmt=	3624	if	st37	==1	&	t26	==1
replace vmt=	2332	if	st38	==1	&	t26	==1
replace vmt=	7477	if	st39	==1	&	t26	==1
replace vmt=	563	if	st40	==1	&	t26	==1
replace vmt=	3752	if	st41	==1	&	t26	==1
replace vmt=	597	if	st42	==1	&	t26	==1
replace vmt=	4983	if	st43	==1	&	t26	==1
replace vmt=	18953	if	st44	==1	&	t26	==1
replace vmt=	1795	if	st45	==1	&	t26	==1
replace vmt=	572	if	st46	==1	&	t26	==1
replace vmt=	5771	if	st47	==1	&	t26	==1
replace vmt=	3917	if	st48	==1	&	t26	==1
replace vmt=	1144	if	st49	==1	&	t26	==1
replace vmt=	4108	if	st50	==1	&	t26	==1
replace vmt=	613	if	st51	==1	&	t26	==1
replace vmt=	5003	if	st1	==1	&	t27	==1
replace vmt=	380	if	st2 	==1	&	t27	==1
replace vmt=	5301	if	st3	==1	&	t27	==1
replace vmt=	2737	if	st4	==1	&	t27	==1
replace vmt=	26093	if	st5	==1	&	t27	==1
replace vmt=	4304	if	st6	==1	&	t27	==1
replace vmt=	2409	if	st7	==1	&	t27	==1
replace vmt=	737	if	st8	==1	&	t27	==1
replace vmt=	321	if	st9	==1	&	t27	==1
replace vmt=	17223	if	st10	==1	&	t27	==1
replace vmt=	9271	if	st11	==1	&	t27	==1
replace vmt=	793	if	st12	==1	&	t27	==1
replace vmt=	1179	if	st13	==1	&	t27	==1
replace vmt=	8053	if	st14	==1	&	t27	==1
replace vmt=	5623	if	st15	==1	&	t27	==1
replace vmt=	2457	if	st16	==1	&	t27	==1
replace vmt=	2286	if	st17	==1	&	t27	==1
replace vmt=	3860	if	st18	==1	&	t27	==1
replace vmt=	3878	if	st19	==1	&	t27	==1
replace vmt=	1222	if	st20	==1	&	t27	==1
replace vmt=	4534	if	st21	==1	&	t27	==1
replace vmt=	4551	if	st22	==1	&	t27	==1
replace vmt=	8400	if	st23	==1	&	t27	==1
replace vmt=	4375	if	st24	==1	&	t27	==1
replace vmt=	3667	if	st25	==1	&	t27	==1
replace vmt=	5308	if	st26	==1	&	t27	==1
replace vmt=	727	if	st27	==1	&	t27	==1
replace vmt=	1572	if	st28	==1	&	t27	==1
replace vmt=	1772	if	st29	==1	&	t27	==1
replace vmt=	1085	if	st30	==1	&	t27	==1
replace vmt=	6378	if	st31	==1	&	t27	==1
replace vmt=	2113	if	st32	==1	&	t27	==1
replace vmt=	11353	if	st33	==1	&	t27	==1
replace vmt=	8373	if	st34	==1	&	t27	==1
replace vmt=	619	if	st35	==1	&	t27	==1
replace vmt=	8949	if	st36	==1	&	t27	==1
replace vmt=	4033	if	st37	==1	&	t27	==1
replace vmt=	2696	if	st38	==1	&	t27	==1
replace vmt=	8636	if	st39	==1	&	t27	==1
replace vmt=	645	if	st40	==1	&	t27	==1
replace vmt=	4123	if	st41	==1	&	t27	==1
replace vmt=	682	if	st42	==1	&	t27	==1
replace vmt=	5690	if	st43	==1	&	t27	==1
replace vmt=	21099	if	st44	==1	&	t27	==1
replace vmt=	2189	if	st45	==1	&	t27	==1
replace vmt=	577	if	st46	==1	&	t27	==1
replace vmt=	6324	if	st47	==1	&	t27	==1
replace vmt=	4237	if	st48	==1	&	t27	==1
replace vmt=	1791	if	st49	==1	&	t27	==1
replace vmt=	4845	if	st50	==1	&	t27	==1
replace vmt=	665	if	st51	==1	&	t27	==1
replace vmt=	5179	if	st1	==1	&	t28	==1
replace vmt=	438	if	st2 	==1	&	t28	==1
replace vmt=	5408	if	st3	==1	&	t28	==1
replace vmt=	2546	if	st4	==1	&	t28	==1
replace vmt=	28019	if	st5	==1	&	t28	==1
replace vmt=	4095	if	st6	==1	&	t28	==1
replace vmt=	2474	if	st7	==1	&	t28	==1
replace vmt=	766	if	st8	==1	&	t28	==1
replace vmt=	316	if	st9	==1	&	t28	==1
replace vmt=	16594	if	st10	==1	&	t28	==1
replace vmt=	9609	if	st11	==1	&	t28	==1
replace vmt=	796	if	st12	==1	&	t28	==1
replace vmt=	1221	if	st13	==1	&	t28	==1
replace vmt=	9008	if	st14	==1	&	t28	==1
replace vmt=	5967	if	st15	==1	&	t28	==1
replace vmt=	2616	if	st16	==1	&	t28	==1
replace vmt=	2442	if	st17	==1	&	t28	==1
replace vmt=	4019	if	st18	==1	&	t28	==1
replace vmt=	3860	if	st19	==1	&	t28	==1
replace vmt=	1181	if	st20	==1	&	t28	==1
replace vmt=	4649	if	st21	==1	&	t28	==1
replace vmt=	4217	if	st22	==1	&	t28	==1
replace vmt=	8298	if	st23	==1	&	t28	==1
replace vmt=	4516	if	st24	==1	&	t28	==1
replace vmt=	3788	if	st25	==1	&	t28	==1
replace vmt=	5600	if	st26	==1	&	t28	==1
replace vmt=	778	if	st27	==1	&	t28	==1
replace vmt=	1600	if	st28	==1	&	t28	==1
replace vmt=	1737	if	st29	==1	&	t28	==1
replace vmt=	1112	if	st30	==1	&	t28	==1
replace vmt=	6296	if	st31	==1	&	t28	==1
replace vmt=	2128	if	st32	==1	&	t28	==1
replace vmt=	11082	if	st33	==1	&	t28	==1
replace vmt=	8589	if	st34	==1	&	t28	==1
replace vmt=	671	if	st35	==1	&	t28	==1
replace vmt=	8821	if	st36	==1	&	t28	==1
replace vmt=	4169	if	st37	==1	&	t28	==1
replace vmt=	2708	if	st38	==1	&	t28	==1
replace vmt=	8988	if	st39	==1	&	t28	==1
replace vmt=	680	if	st40	==1	&	t28	==1
replace vmt=	4258	if	st41	==1	&	t28	==1
replace vmt=	696	if	st42	==1	&	t28	==1
replace vmt=	5703	if	st43	==1	&	t28	==1
replace vmt=	20180	if	st44	==1	&	t28	==1
replace vmt=	2211	if	st45	==1	&	t28	==1
replace vmt=	543	if	st46	==1	&	t28	==1
replace vmt=	6787	if	st47	==1	&	t28	==1
replace vmt=	4720	if	st48	==1	&	t28	==1
replace vmt=	1689	if	st49	==1	&	t28	==1
replace vmt=	4877	if	st50	==1	&	t28	==1
replace vmt=	708	if	st51	==1	&	t28	==1
replace vmt=	5197	if	st1	==1	&	t29	==1
replace vmt=	499	if	st2 	==1	&	t29	==1
replace vmt=	5551	if	st3	==1	&	t29	==1
replace vmt=	2810	if	st4	==1	&	t29	==1
replace vmt=	26929	if	st5	==1	&	t29	==1
replace vmt=	4012	if	st6	==1	&	t29	==1
replace vmt=	2784	if	st7	==1	&	t29	==1
replace vmt=	795	if	st8	==1	&	t29	==1
replace vmt=	328	if	st9	==1	&	t29	==1
replace vmt=	16388	if	st10	==1	&	t29	==1
replace vmt=	9499	if	st11	==1	&	t29	==1
replace vmt=	623	if	st12	==1	&	t29	==1
replace vmt=	1328	if	st13	==1	&	t29	==1
replace vmt=	9278	if	st14	==1	&	t29	==1
replace vmt=	6062	if	st15	==1	&	t29	==1
replace vmt=	2818	if	st16	==1	&	t29	==1
replace vmt=	2576	if	st17	==1	&	t29	==1
replace vmt=	4154	if	st18	==1	&	t29	==1
replace vmt=	3861	if	st19	==1	&	t29	==1
replace vmt=	1276	if	st20	==1	&	t29	==1
replace vmt=	4969	if	st21	==1	&	t29	==1
replace vmt=	4583	if	st22	==1	&	t29	==1
replace vmt=	8754	if	st23	==1	&	t29	==1
replace vmt=	4975	if	st24	==1	&	t29	==1
replace vmt=	3789	if	st25	==1	&	t29	==1
replace vmt=	6109	if	st26	==1	&	t29	==1
replace vmt=	932	if	st27	==1	&	t29	==1
replace vmt=	1762	if	st28	==1	&	t29	==1
replace vmt=	1931	if	st29	==1	&	t29	==1
replace vmt=	1072	if	st30	==1	&	t29	==1
replace vmt=	6262	if	st31	==1	&	t29	==1
replace vmt=	2276	if	st32	==1	&	t29	==1
replace vmt=	11917	if	st33	==1	&	t29	==1
replace vmt=	8750	if	st34	==1	&	t29	==1
replace vmt=	726	if	st35	==1	&	t29	==1
replace vmt=	9351	if	st36	==1	&	t29	==1
replace vmt=	4328	if	st37	==1	&	t29	==1
replace vmt=	3007	if	st38	==1	&	t29	==1
replace vmt=	9226	if	st39	==1	&	t29	==1
replace vmt=	770	if	st40	==1	&	t29	==1
replace vmt=	4316	if	st41	==1	&	t29	==1
replace vmt=	810	if	st42	==1	&	t29	==1
replace vmt=	5674	if	st43	==1	&	t29	==1
replace vmt=	20753	if	st44	==1	&	t29	==1
replace vmt=	2163	if	st45	==1	&	t29	==1
replace vmt=	649	if	st46	==1	&	t29	==1
replace vmt=	7041	if	st47	==1	&	t29	==1
replace vmt=	5171	if	st48	==1	&	t29	==1
replace vmt=	1806	if	st49	==1	&	t29	==1
replace vmt=	5271	if	st50	==1	&	t29	==1
replace vmt=	802	if	st51	==1	&	t29	==1
replace vmt=	5167	if	st1	==1	&	t30	==1
replace vmt=	473	if	st2 	==1	&	t30	==1
replace vmt=	5759	if	st3	==1	&	t30	==1
replace vmt=	2908	if	st4	==1	&	t30	==1
replace vmt=	28050	if	st5	==1	&	t30	==1
replace vmt=	3790	if	st6	==1	&	t30	==1
replace vmt=	2678	if	st7	==1	&	t30	==1
replace vmt=	885	if	st8	==1	&	t30	==1
replace vmt=	343	if	st9	==1	&	t30	==1
replace vmt=	16279	if	st10	==1	&	t30	==1
replace vmt=	8823	if	st11	==1	&	t30	==1
replace vmt=	818	if	st12	==1	&	t30	==1
replace vmt=	1343	if	st13	==1	&	t30	==1
replace vmt=	10088	if	st14	==1	&	t30	==1
replace vmt=	6058	if	st15	==1	&	t30	==1
replace vmt=	2775	if	st16	==1	&	t30	==1
replace vmt=	2519	if	st17	==1	&	t30	==1
replace vmt=	4100	if	st18	==1	&	t30	==1
replace vmt=	4084	if	st19	==1	&	t30	==1
replace vmt=	1300	if	st20	==1	&	t30	==1
replace vmt=	4968	if	st21	==1	&	t30	==1
replace vmt=	4687	if	st22	==1	&	t30	==1
replace vmt=	8686	if	st23	==1	&	t30	==1
replace vmt=	4956	if	st24	==1	&	t30	==1
replace vmt=	3732	if	st25	==1	&	t30	==1
replace vmt=	5980	if	st26	==1	&	t30	==1
replace vmt=	1076	if	st27	==1	&	t30	==1
replace vmt=	1744	if	st28	==1	&	t30	==1
replace vmt=	1683	if	st29	==1	&	t30	==1
replace vmt=	1150	if	st30	==1	&	t30	==1
replace vmt=	6358	if	st31	==1	&	t30	==1
replace vmt=	2138	if	st32	==1	&	t30	==1
replace vmt=	11505	if	st33	==1	&	t30	==1
replace vmt=	8719	if	st34	==1	&	t30	==1
replace vmt=	756	if	st35	==1	&	t30	==1
replace vmt=	9360	if	st36	==1	&	t30	==1
replace vmt=	4013	if	st37	==1	&	t30	==1
replace vmt=	3003	if	st38	==1	&	t30	==1
replace vmt=	9326	if	st39	==1	&	t30	==1
replace vmt=	753	if	st40	==1	&	t30	==1
replace vmt=	4250	if	st41	==1	&	t30	==1
replace vmt=	870	if	st42	==1	&	t30	==1
replace vmt=	5904	if	st43	==1	&	t30	==1
replace vmt=	20033	if	st44	==1	&	t30	==1
replace vmt=	2129	if	st45	==1	&	t30	==1
replace vmt=	628	if	st46	==1	&	t30	==1
replace vmt=	6960	if	st47	==1	&	t30	==1
replace vmt=	5052	if	st48	==1	&	t30	==1
replace vmt=	1813	if	st49	==1	&	t30	==1
replace vmt=	5188	if	st50	==1	&	t30	==1
replace vmt=	852	if	st51	==1	&	t30	==1
replace vmt=	5186	if	st1	==1	&	t31	==1
replace vmt=	501	if	st2 	==1	&	t31	==1
replace vmt=	5008	if	st3	==1	&	t31	==1
replace vmt=	3044	if	st4	==1	&	t31	==1
replace vmt=	28126	if	st5	==1	&	t31	==1
replace vmt=	4038	if	st6	==1	&	t31	==1
replace vmt=	2828	if	st7	==1	&	t31	==1
replace vmt=	945	if	st8	==1	&	t31	==1
replace vmt=	244	if	st9	==1	&	t31	==1
replace vmt=	16592	if	st10	==1	&	t31	==1
replace vmt=	9129	if	st11	==1	&	t31	==1
replace vmt=	843	if	st12	==1	&	t31	==1
replace vmt=	1477	if	st13	==1	&	t31	==1
replace vmt=	9269	if	st14	==1	&	t31	==1
replace vmt=	6292	if	st15	==1	&	t31	==1
replace vmt=	2818	if	st16	==1	&	t31	==1
replace vmt=	2663	if	st17	==1	&	t31	==1
replace vmt=	4169	if	st18	==1	&	t31	==1
replace vmt=	4141	if	st19	==1	&	t31	==1
replace vmt=	1341	if	st20	==1	&	t31	==1
replace vmt=	4966	if	st21	==1	&	t31	==1
replace vmt=	5018	if	st22	==1	&	t31	==1
replace vmt=	8777	if	st23	==1	&	t31	==1
replace vmt=	4811	if	st24	==1	&	t31	==1
replace vmt=	3869	if	st25	==1	&	t31	==1
replace vmt=	6359	if	st26	==1	&	t31	==1
replace vmt=	1297	if	st27	==1	&	t31	==1
replace vmt=	1849	if	st28	==1	&	t31	==1
replace vmt=	1783	if	st29	==1	&	t31	==1
replace vmt=	1232	if	st30	==1	&	t31	==1
replace vmt=	6281	if	st31	==1	&	t31	==1
replace vmt=	2412	if	st32	==1	&	t31	==1
replace vmt=	11950	if	st33	==1	&	t31	==1
replace vmt=	8942	if	st34	==1	&	t31	==1
replace vmt=	853	if	st35	==1	&	t31	==1
replace vmt=	9728	if	st36	==1	&	t31	==1
replace vmt=	4333	if	st37	==1	&	t31	==1
replace vmt=	3267	if	st38	==1	&	t31	==1
replace vmt=	9865	if	st39	==1	&	t31	==1
replace vmt=	834	if	st40	==1	&	t31	==1
replace vmt=	4435	if	st41	==1	&	t31	==1
replace vmt=	959	if	st42	==1	&	t31	==1
replace vmt=	6235	if	st43	==1	&	t31	==1
replace vmt=	20643	if	st44	==1	&	t31	==1
replace vmt=	2355	if	st45	==1	&	t31	==1
replace vmt=	750	if	st46	==1	&	t31	==1
replace vmt=	7306	if	st47	==1	&	t31	==1
replace vmt=	5384	if	st48	==1	&	t31	==1
replace vmt=	1797	if	st49	==1	&	t31	==1
replace vmt=	5489	if	st50	==1	&	t31	==1
replace vmt=	949	if	st51	==1	&	t31	==1
replace vmt=	5241	if	st1	==1	&	t32	==1
replace vmt=	484	if	st2 	==1	&	t32	==1
replace vmt=	4376	if	st3	==1	&	t32	==1
replace vmt=	2916	if	st4	==1	&	t32	==1
replace vmt=	28399	if	st5	==1	&	t32	==1
replace vmt=	4399	if	st6	==1	&	t32	==1
replace vmt=	2788	if	st7	==1	&	t32	==1
replace vmt=	913	if	st8	==1	&	t32	==1
replace vmt=	339	if	st9	==1	&	t32	==1
replace vmt=	16328	if	st10	==1	&	t32	==1
replace vmt=	8754	if	st11	==1	&	t32	==1
replace vmt=	799	if	st12	==1	&	t32	==1
replace vmt=	1445	if	st13	==1	&	t32	==1
replace vmt=	8880	if	st14	==1	&	t32	==1
replace vmt=	5666	if	st15	==1	&	t32	==1
replace vmt=	2744	if	st16	==1	&	t32	==1
replace vmt=	2584	if	st17	==1	&	t32	==1
replace vmt=	4083	if	st18	==1	&	t32	==1
replace vmt=	4344	if	st19	==1	&	t32	==1
replace vmt=	1307	if	st20	==1	&	t32	==1
replace vmt=	5150	if	st21	==1	&	t32	==1
replace vmt=	4731	if	st22	==1	&	t32	==1
replace vmt=	8486	if	st23	==1	&	t32	==1
replace vmt=	4971	if	st24	==1	&	t32	==1
replace vmt=	3534	if	st25	==1	&	t32	==1
replace vmt=	6263	if	st26	==1	&	t32	==1
replace vmt=	1247	if	st27	==1	&	t32	==1
replace vmt=	1805	if	st28	==1	&	t32	==1
replace vmt=	1750	if	st29	==1	&	t32	==1
replace vmt=	1246	if	st30	==1	&	t32	==1
replace vmt=	6129	if	st31	==1	&	t32	==1
replace vmt=	2241	if	st32	==1	&	t32	==1
replace vmt=	12244	if	st33	==1	&	t32	==1
replace vmt=	8764	if	st34	==1	&	t32	==1
replace vmt=	781	if	st35	==1	&	t32	==1
replace vmt=	9181	if	st36	==1	&	t32	==1
replace vmt=	4450	if	st37	==1	&	t32	==1
replace vmt=	3263	if	st38	==1	&	t32	==1
replace vmt=	9727	if	st39	==1	&	t32	==1
replace vmt=	889	if	st40	==1	&	t32	==1
replace vmt=	4202	if	st41	==1	&	t32	==1
replace vmt=	887	if	st42	==1	&	t32	==1
replace vmt=	5814	if	st43	==1	&	t32	==1
replace vmt=	20706	if	st44	==1	&	t32	==1
replace vmt=	2425	if	st45	==1	&	t32	==1
replace vmt=	730	if	st46	==1	&	t32	==1
replace vmt=	7150	if	st47	==1	&	t32	==1
replace vmt=	5380	if	st48	==1	&	t32	==1
replace vmt=	1805	if	st49	==1	&	t32	==1
replace vmt=	5349	if	st50	==1	&	t32	==1
replace vmt=	912	if	st51	==1	&	t32	==1
replace vmt=	4623	if	st1	==1	&	t33	==1
replace vmt=	429	if	st2 	==1	&	t33	==1
replace vmt=	4425	if	st3	==1	&	t33	==1
replace vmt=	2510	if	st4	==1	&	t33	==1
replace vmt=	23100	if	st5	==1	&	t33	==1
replace vmt=	4053	if	st6	==1	&	t33	==1
replace vmt=	2623	if	st7	==1	&	t33	==1
replace vmt=	839	if	st8	==1	&	t33	==1
replace vmt=	303	if	st9	==1	&	t33	==1
replace vmt=	15469	if	st10	==1	&	t33	==1
replace vmt=	8214	if	st11	==1	&	t33	==1
replace vmt=	1024	if	st12	==1	&	t33	==1
replace vmt=	1316	if	st13	==1	&	t33	==1
replace vmt=	8475	if	st14	==1	&	t33	==1
replace vmt=	5657	if	st15	==1	&	t33	==1
replace vmt=	2704	if	st16	==1	&	t33	==1
replace vmt=	2419	if	st17	==1	&	t33	==1
replace vmt=	3791	if	st18	==1	&	t33	==1
replace vmt=	3512	if	st19	==1	&	t33	==1
replace vmt=	1208	if	st20	==1	&	t33	==1
replace vmt=	4367	if	st21	==1	&	t33	==1
replace vmt=	4365	if	st22	==1	&	t33	==1
replace vmt=	8107	if	st23	==1	&	t33	==1
replace vmt=	4702	if	st24	==1	&	t33	==1
replace vmt=	3373	if	st25	==1	&	t33	==1
replace vmt=	6249	if	st26	==1	&	t33	==1
replace vmt=	1009	if	st27	==1	&	t33	==1
replace vmt=	1681	if	st28	==1	&	t33	==1
replace vmt=	1690	if	st29	==1	&	t33	==1
replace vmt=	1099	if	st30	==1	&	t33	==1
replace vmt=	6549	if	st31	==1	&	t33	==1
replace vmt=	2092	if	st32	==1	&	t33	==1
replace vmt=	11393	if	st33	==1	&	t33	==1
replace vmt=	8223	if	st34	==1	&	t33	==1
replace vmt=	683	if	st35	==1	&	t33	==1
replace vmt=	8953	if	st36	==1	&	t33	==1
replace vmt=	4018	if	st37	==1	&	t33	==1
replace vmt=	2907	if	st38	==1	&	t33	==1
replace vmt=	9072	if	st39	==1	&	t33	==1
replace vmt=	1093	if	st40	==1	&	t33	==1
replace vmt=	3956	if	st41	==1	&	t33	==1
replace vmt=	775	if	st42	==1	&	t33	==1
replace vmt=	5490	if	st43	==1	&	t33	==1
replace vmt=	19730	if	st44	==1	&	t33	==1
replace vmt=	2157	if	st45	==1	&	t33	==1
replace vmt=	624	if	st46	==1	&	t33	==1
replace vmt=	6671	if	st47	==1	&	t33	==1
replace vmt=	5013	if	st48	==1	&	t33	==1
replace vmt=	1801	if	st49	==1	&	t33	==1
replace vmt=	4907	if	st50	==1	&	t33	==1
replace vmt=	831	if	st51	==1	&	t33	==1
replace vmt=	4694	if	st1	==1	&	t34	==1
replace vmt=	450	if	st2 	==1	&	t34	==1
replace vmt=	4878	if	st3	==1	&	t34	==1
replace vmt=	2662	if	st4	==1	&	t34	==1
replace vmt=	27004	if	st5	==1	&	t34	==1
replace vmt=	4021	if	st6	==1	&	t34	==1
replace vmt=	2778	if	st7	==1	&	t34	==1
replace vmt=	787	if	st8	==1	&	t34	==1
replace vmt=	321	if	st9	==1	&	t34	==1
replace vmt=	16425	if	st10	==1	&	t34	==1
replace vmt=	9211	if	st11	==1	&	t34	==1
replace vmt=	1116	if	st12	==1	&	t34	==1
replace vmt=	1286	if	st13	==1	&	t34	==1
replace vmt=	9106	if	st14	==1	&	t34	==1
replace vmt=	6174	if	st15	==1	&	t34	==1
replace vmt=	2743	if	st16	==1	&	t34	==1
replace vmt=	2468	if	st17	==1	&	t34	==1
replace vmt=	4091	if	st18	==1	&	t34	==1
replace vmt=	3864	if	st19	==1	&	t34	==1
replace vmt=	1237	if	st20	==1	&	t34	==1
replace vmt=	4889	if	st21	==1	&	t34	==1
replace vmt=	4722	if	st22	==1	&	t34	==1
replace vmt=	8293	if	st23	==1	&	t34	==1
replace vmt=	4774	if	st24	==1	&	t34	==1
replace vmt=	3374	if	st25	==1	&	t34	==1
replace vmt=	5559	if	st26	==1	&	t34	==1
replace vmt=	898	if	st27	==1	&	t34	==1
replace vmt=	1701	if	st28	==1	&	t34	==1
replace vmt=	1739	if	st29	==1	&	t34	==1
replace vmt=	1129	if	st30	==1	&	t34	==1
replace vmt=	6422	if	st31	==1	&	t34	==1
replace vmt=	2348	if	st32	==1	&	t34	==1
replace vmt=	11145	if	st33	==1	&	t34	==1
replace vmt=	8827	if	st34	==1	&	t34	==1
replace vmt=	758	if	st35	==1	&	t34	==1
replace vmt=	9241	if	st36	==1	&	t34	==1
replace vmt=	3920	if	st37	==1	&	t34	==1
replace vmt=	2799	if	st38	==1	&	t34	==1
replace vmt=	9350	if	st39	==1	&	t34	==1
replace vmt=	602	if	st40	==1	&	t34	==1
replace vmt=	3983	if	st41	==1	&	t34	==1
replace vmt=	731	if	st42	==1	&	t34	==1
replace vmt=	5591	if	st43	==1	&	t34	==1
replace vmt=	20439	if	st44	==1	&	t34	==1
replace vmt=	2139	if	st45	==1	&	t34	==1
replace vmt=	629	if	st46	==1	&	t34	==1
replace vmt=	6907	if	st47	==1	&	t34	==1
replace vmt=	4694	if	st48	==1	&	t34	==1
replace vmt=	1786	if	st49	==1	&	t34	==1
replace vmt=	4872	if	st50	==1	&	t34	==1
replace vmt=	795	if	st51	==1	&	t34	==1
replace vmt=	4565	if	st1	==1	&	t35	==1
replace vmt=	364	if	st2 	==1	&	t35	==1
replace vmt=	4616	if	st3	==1	&	t35	==1
replace vmt=	2527	if	st4	==1	&	t35	==1
replace vmt=	28191	if	st5	==1	&	t35	==1
replace vmt=	3565	if	st6	==1	&	t35	==1
replace vmt=	2580	if	st7	==1	&	t35	==1
replace vmt=	702	if	st8	==1	&	t35	==1
replace vmt=	286	if	st9	==1	&	t35	==1
replace vmt=	15727	if	st10	==1	&	t35	==1
replace vmt=	8256	if	st11	==1	&	t35	==1
replace vmt=	786	if	st12	==1	&	t35	==1
replace vmt=	1163	if	st13	==1	&	t35	==1
replace vmt=	7714	if	st14	==1	&	t35	==1
replace vmt=	5427	if	st15	==1	&	t35	==1
replace vmt=	2479	if	st16	==1	&	t35	==1
replace vmt=	2475	if	st17	==1	&	t35	==1
replace vmt=	3841	if	st18	==1	&	t35	==1
replace vmt=	3822	if	st19	==1	&	t35	==1
replace vmt=	1117	if	st20	==1	&	t35	==1
replace vmt=	4467	if	st21	==1	&	t35	==1
replace vmt=	4317	if	st22	==1	&	t35	==1
replace vmt=	7558	if	st23	==1	&	t35	==1
replace vmt=	4607	if	st24	==1	&	t35	==1
replace vmt=	3383	if	st25	==1	&	t35	==1
replace vmt=	5395	if	st26	==1	&	t35	==1
replace vmt=	872	if	st27	==1	&	t35	==1
replace vmt=	1610	if	st28	==1	&	t35	==1
replace vmt=	1650	if	st29	==1	&	t35	==1
replace vmt=	981	if	st30	==1	&	t35	==1
replace vmt=	6268	if	st31	==1	&	t35	==1
replace vmt=	2037	if	st32	==1	&	t35	==1
replace vmt=	10295	if	st33	==1	&	t35	==1
replace vmt=	7774	if	st34	==1	&	t35	==1
replace vmt=	648	if	st35	==1	&	t35	==1
replace vmt=	8923	if	st36	==1	&	t35	==1
replace vmt=	3930	if	st37	==1	&	t35	==1
replace vmt=	2522	if	st38	==1	&	t35	==1
replace vmt=	8521	if	st39	==1	&	t35	==1
replace vmt=	598	if	st40	==1	&	t35	==1
replace vmt=	3758	if	st41	==1	&	t35	==1
replace vmt=	702	if	st42	==1	&	t35	==1
replace vmt=	5143	if	st43	==1	&	t35	==1
replace vmt=	19367	if	st44	==1	&	t35	==1
replace vmt=	1958	if	st45	==1	&	t35	==1
replace vmt=	518	if	st46	==1	&	t35	==1
replace vmt=	6364	if	st47	==1	&	t35	==1
replace vmt=	4225	if	st48	==1	&	t35	==1
replace vmt=	1616	if	st49	==1	&	t35	==1
replace vmt=	4566	if	st50	==1	&	t35	==1
replace vmt=	705	if	st51	==1	&	t35	==1
replace vmt=	4617	if	st1	==1	&	t36	==1
replace vmt=	355	if	st2 	==1	&	t36	==1
replace vmt=	5340	if	st3	==1	&	t36	==1
replace vmt=	2852	if	st4	==1	&	t36	==1
replace vmt=	28729	if	st5	==1	&	t36	==1
replace vmt=	3569	if	st6	==1	&	t36	==1
replace vmt=	2598	if	st7	==1	&	t36	==1
replace vmt=	668	if	st8	==1	&	t36	==1
replace vmt=	274	if	st9	==1	&	t36	==1
replace vmt=	16206	if	st10	==1	&	t36	==1
replace vmt=	9134	if	st11	==1	&	t36	==1
replace vmt=	858	if	st12	==1	&	t36	==1
replace vmt=	1103	if	st13	==1	&	t36	==1
replace vmt=	7756	if	st14	==1	&	t36	==1
replace vmt=	5829	if	st15	==1	&	t36	==1
replace vmt=	2240	if	st16	==1	&	t36	==1
replace vmt=	2500	if	st17	==1	&	t36	==1
replace vmt=	3891	if	st18	==1	&	t36	==1
replace vmt=	3423	if	st19	==1	&	t36	==1
replace vmt=	1138	if	st20	==1	&	t36	==1
replace vmt=	4123	if	st21	==1	&	t36	==1
replace vmt=	4714	if	st22	==1	&	t36	==1
replace vmt=	8083	if	st23	==1	&	t36	==1
replace vmt=	4429	if	st24	==1	&	t36	==1
replace vmt=	3075	if	st25	==1	&	t36	==1
replace vmt=	5653	if	st26	==1	&	t36	==1
replace vmt=	811	if	st27	==1	&	t36	==1
replace vmt=	1411	if	st28	==1	&	t36	==1
replace vmt=	1646	if	st29	==1	&	t36	==1
replace vmt=	1060	if	st30	==1	&	t36	==1
replace vmt=	6182	if	st31	==1	&	t36	==1
replace vmt=	2111	if	st32	==1	&	t36	==1
replace vmt=	11315	if	st33	==1	&	t36	==1
replace vmt=	7910	if	st34	==1	&	t36	==1
replace vmt=	663	if	st35	==1	&	t36	==1
replace vmt=	8824	if	st36	==1	&	t36	==1
replace vmt=	3624	if	st37	==1	&	t36	==1
replace vmt=	2643	if	st38	==1	&	t36	==1
replace vmt=	9442	if	st39	==1	&	t36	==1
replace vmt=	626	if	st40	==1	&	t36	==1
replace vmt=	3881	if	st41	==1	&	t36	==1
replace vmt=	685	if	st42	==1	&	t36	==1
replace vmt=	5799	if	st43	==1	&	t36	==1
replace vmt=	18274	if	st44	==1	&	t36	==1
replace vmt=	1937	if	st45	==1	&	t36	==1
replace vmt=	554	if	st46	==1	&	t36	==1
replace vmt=	6356	if	st47	==1	&	t36	==1
replace vmt=	4301	if	st48	==1	&	t36	==1
replace vmt=	1656	if	st49	==1	&	t36	==1
replace vmt=	4315	if	st50	==1	&	t36	==1
replace vmt=	738	if	st51	==1	&	t36	==1
replace vmt=	4428	if	st1	==1	&	t37	==1
replace vmt=	333	if	st2 	==1	&	t37	==1
replace vmt=	4672	if	st3	==1	&	t37	==1
replace vmt=	2735	if	st4	==1	&	t37	==1
replace vmt=	21812	if	st5	==1	&	t37	==1
replace vmt=	3932	if	st6	==1	&	t37	==1
replace vmt=	2444	if	st7	==1	&	t37	==1
replace vmt=	658	if	st8	==1	&	t37	==1
replace vmt=	294	if	st9	==1	&	t37	==1
replace vmt=	16203	if	st10	==1	&	t37	==1
replace vmt=	8493	if	st11	==1	&	t37	==1
replace vmt=	793	if	st12	==1	&	t37	==1
replace vmt=	1109	if	st13	==1	&	t37	==1
replace vmt=	7414	if	st14	==1	&	t37	==1
replace vmt=	5712	if	st15	==1	&	t37	==1
replace vmt=	2087	if	st16	==1	&	t37	==1
replace vmt=	2148	if	st17	==1	&	t37	==1
replace vmt=	3506	if	st18	==1	&	t37	==1
replace vmt=	3640	if	st19	==1	&	t37	==1
replace vmt=	1099	if	st20	==1	&	t37	==1
replace vmt=	4046	if	st21	==1	&	t37	==1
replace vmt=	4633	if	st22	==1	&	t37	==1
replace vmt=	8364	if	st23	==1	&	t37	==1
replace vmt=	4180	if	st24	==1	&	t37	==1
replace vmt=	3407	if	st25	==1	&	t37	==1
replace vmt=	4936	if	st26	==1	&	t37	==1
replace vmt=	648	if	st27	==1	&	t37	==1
replace vmt=	1347	if	st28	==1	&	t37	==1
replace vmt=	1508	if	st29	==1	&	t37	==1
replace vmt=	985	if	st30	==1	&	t37	==1
replace vmt=	5113	if	st31	==1	&	t37	==1
replace vmt=	2126	if	st32	==1	&	t37	==1
replace vmt=	10157	if	st33	==1	&	t37	==1
replace vmt=	7682	if	st34	==1	&	t37	==1
replace vmt=	600	if	st35	==1	&	t37	==1
replace vmt=	8274	if	st36	==1	&	t37	==1
replace vmt=	3400	if	st37	==1	&	t37	==1
replace vmt=	2462	if	st38	==1	&	t37	==1
replace vmt=	7355	if	st39	==1	&	t37	==1
replace vmt=	438	if	st40	==1	&	t37	==1
replace vmt=	3788	if	st41	==1	&	t37	==1
replace vmt=	593	if	st42	==1	&	t37	==1
replace vmt=	5238	if	st43	==1	&	t37	==1
replace vmt=	18649	if	st44	==1	&	t37	==1
replace vmt=	1924	if	st45	==1	&	t37	==1
replace vmt=	673	if	st46	==1	&	t37	==1
replace vmt=	6053	if	st47	==1	&	t37	==1
replace vmt=	4037	if	st48	==1	&	t37	==1
replace vmt=	1435	if	st49	==1	&	t37	==1
replace vmt=	4284	if	st50	==1	&	t37	==1
replace vmt=	664	if	st51	==1	&	t37	==1
replace vmt=	4357	if	st1	==1	&	t38	==1
replace vmt=	329	if	st2 	==1	&	t38	==1
replace vmt=	5158	if	st3	==1	&	t38	==1
replace vmt=	2464	if	st4	==1	&	t38	==1
replace vmt=	22729	if	st5	==1	&	t38	==1
replace vmt=	3487	if	st6	==1	&	t38	==1
replace vmt=	2221	if	st7	==1	&	t38	==1
replace vmt=	553	if	st8	==1	&	t38	==1
replace vmt=	289	if	st9	==1	&	t38	==1
replace vmt=	15095	if	st10	==1	&	t38	==1
replace vmt=	8165	if	st11	==1	&	t38	==1
replace vmt=	650	if	st12	==1	&	t38	==1
replace vmt=	1106	if	st13	==1	&	t38	==1
replace vmt=	7629	if	st14	==1	&	t38	==1
replace vmt=	4892	if	st15	==1	&	t38	==1
replace vmt=	2047	if	st16	==1	&	t38	==1
replace vmt=	2226	if	st17	==1	&	t38	==1
replace vmt=	3132	if	st18	==1	&	t38	==1
replace vmt=	3292	if	st19	==1	&	t38	==1
replace vmt=	1104	if	st20	==1	&	t38	==1
replace vmt=	3241	if	st21	==1	&	t38	==1
replace vmt=	4258	if	st22	==1	&	t38	==1
replace vmt=	7421	if	st23	==1	&	t38	==1
replace vmt=	4001	if	st24	==1	&	t38	==1
replace vmt=	3306	if	st25	==1	&	t38	==1
replace vmt=	4587	if	st26	==1	&	t38	==1
replace vmt=	673	if	st27	==1	&	t38	==1
replace vmt=	1340	if	st28	==1	&	t38	==1
replace vmt=	1414	if	st29	==1	&	t38	==1
replace vmt=	956	if	st30	==1	&	t38	==1
replace vmt=	4933	if	st31	==1	&	t38	==1
replace vmt=	1961	if	st32	==1	&	t38	==1
replace vmt=	9417	if	st33	==1	&	t38	==1
replace vmt=	7278	if	st34	==1	&	t38	==1
replace vmt=	550	if	st35	==1	&	t38	==1
replace vmt=	7239	if	st36	==1	&	t38	==1
replace vmt=	3470	if	st37	==1	&	t38	==1
replace vmt=	2440	if	st38	==1	&	t38	==1
replace vmt=	6686	if	st39	==1	&	t38	==1
replace vmt=	554	if	st40	==1	&	t38	==1
replace vmt=	3748	if	st41	==1	&	t38	==1
replace vmt=	602	if	st42	==1	&	t38	==1
replace vmt=	5091	if	st43	==1	&	t38	==1
replace vmt=	18490	if	st44	==1	&	t38	==1
replace vmt=	1829	if	st45	==1	&	t38	==1
replace vmt=	563	if	st46	==1	&	t38	==1
replace vmt=	5391	if	st47	==1	&	t38	==1
replace vmt=	4098	if	st48	==1	&	t38	==1
replace vmt=	1226	if	st49	==1	&	t38	==1
replace vmt=	4149	if	st50	==1	&	t38	==1
replace vmt=	628	if	st51	==1	&	t38	==1
replace vmt=	5160	if	st1	==1	&	t39	==1
replace vmt=	393	if	st2 	==1	&	t39	==1
replace vmt=	5495	if	st3	==1	&	t39	==1
replace vmt=	2905	if	st4	==1	&	t39	==1
replace vmt=	27324	if	st5	==1	&	t39	==1
replace vmt=	4358	if	st6	==1	&	t39	==1
replace vmt=	2566	if	st7	==1	&	t39	==1
replace vmt=	740	if	st8	==1	&	t39	==1
replace vmt=	348	if	st9	==1	&	t39	==1
replace vmt=	17543	if	st10	==1	&	t39	==1
replace vmt=	9433	if	st11	==1	&	t39	==1
replace vmt=	798	if	st12	==1	&	t39	==1
replace vmt=	1266	if	st13	==1	&	t39	==1
replace vmt=	8544	if	st14	==1	&	t39	==1
replace vmt=	6010	if	st15	==1	&	t39	==1
replace vmt=	2548	if	st16	==1	&	t39	==1
replace vmt=	2438	if	st17	==1	&	t39	==1
replace vmt=	3897	if	st18	==1	&	t39	==1
replace vmt=	3818	if	st19	==1	&	t39	==1
replace vmt=	1284	if	st20	==1	&	t39	==1
replace vmt=	4748	if	st21	==1	&	t39	==1
replace vmt=	4734	if	st22	==1	&	t39	==1
replace vmt=	8567	if	st23	==1	&	t39	==1
replace vmt=	4788	if	st24	==1	&	t39	==1
replace vmt=	3971	if	st25	==1	&	t39	==1
replace vmt=	5416	if	st26	==1	&	t39	==1
replace vmt=	788	if	st27	==1	&	t39	==1
replace vmt=	1617	if	st28	==1	&	t39	==1
replace vmt=	1743	if	st29	==1	&	t39	==1
replace vmt=	1117	if	st30	==1	&	t39	==1
replace vmt=	6482	if	st31	==1	&	t39	==1
replace vmt=	2169	if	st32	==1	&	t39	==1
replace vmt=	11827	if	st33	==1	&	t39	==1
replace vmt=	8825	if	st34	==1	&	t39	==1
replace vmt=	660	if	st35	==1	&	t39	==1
replace vmt=	9187	if	st36	==1	&	t39	==1
replace vmt=	4088	if	st37	==1	&	t39	==1
replace vmt=	2850	if	st38	==1	&	t39	==1
replace vmt=	8753	if	st39	==1	&	t39	==1
replace vmt=	638	if	st40	==1	&	t39	==1
replace vmt=	4351	if	st41	==1	&	t39	==1
replace vmt=	757	if	st42	==1	&	t39	==1
replace vmt=	6058	if	st43	==1	&	t39	==1
replace vmt=	21357	if	st44	==1	&	t39	==1
replace vmt=	2268	if	st45	==1	&	t39	==1
replace vmt=	586	if	st46	==1	&	t39	==1
replace vmt=	6991	if	st47	==1	&	t39	==1
replace vmt=	4538	if	st48	==1	&	t39	==1
replace vmt=	1892	if	st49	==1	&	t39	==1
replace vmt=	5083	if	st50	==1	&	t39	==1
replace vmt=	684	if	st51	==1	&	t39	==1
replace vmt=	5288	if	st1	==1	&	t40	==1
replace vmt=	443	if	st2 	==1	&	t40	==1
replace vmt=	5491	if	st3	==1	&	t40	==1
replace vmt=	2723	if	st4	==1	&	t40	==1
replace vmt=	28944	if	st5	==1	&	t40	==1
replace vmt=	4276	if	st6	==1	&	t40	==1
replace vmt=	2569	if	st7	==1	&	t40	==1
replace vmt=	789	if	st8	==1	&	t40	==1
replace vmt=	301	if	st9	==1	&	t40	==1
replace vmt=	16834	if	st10	==1	&	t40	==1
replace vmt=	9716	if	st11	==1	&	t40	==1
replace vmt=	818	if	st12	==1	&	t40	==1
replace vmt=	1262	if	st13	==1	&	t40	==1
replace vmt=	8837	if	st14	==1	&	t40	==1
replace vmt=	6413	if	st15	==1	&	t40	==1
replace vmt=	2723	if	st16	==1	&	t40	==1
replace vmt=	2624	if	st17	==1	&	t40	==1
replace vmt=	4231	if	st18	==1	&	t40	==1
replace vmt=	3829	if	st19	==1	&	t40	==1
replace vmt=	1216	if	st20	==1	&	t40	==1
replace vmt=	4746	if	st21	==1	&	t40	==1
replace vmt=	4239	if	st22	==1	&	t40	==1
replace vmt=	8475	if	st23	==1	&	t40	==1
replace vmt=	4853	if	st24	==1	&	t40	==1
replace vmt=	4071	if	st25	==1	&	t40	==1
replace vmt=	5812	if	st26	==1	&	t40	==1
replace vmt=	812	if	st27	==1	&	t40	==1
replace vmt=	1684	if	st28	==1	&	t40	==1
replace vmt=	1690	if	st29	==1	&	t40	==1
replace vmt=	1110	if	st30	==1	&	t40	==1
replace vmt=	6376	if	st31	==1	&	t40	==1
replace vmt=	2153	if	st32	==1	&	t40	==1
replace vmt=	11294	if	st33	==1	&	t40	==1
replace vmt=	8760	if	st34	==1	&	t40	==1
replace vmt=	727	if	st35	==1	&	t40	==1
replace vmt=	9109	if	st36	==1	&	t40	==1
replace vmt=	4222	if	st37	==1	&	t40	==1
replace vmt=	2717	if	st38	==1	&	t40	==1
replace vmt=	9097	if	st39	==1	&	t40	==1
replace vmt=	667	if	st40	==1	&	t40	==1
replace vmt=	4389	if	st41	==1	&	t40	==1
replace vmt=	756	if	st42	==1	&	t40	==1
replace vmt=	6084	if	st43	==1	&	t40	==1
replace vmt=	20333	if	st44	==1	&	t40	==1
replace vmt=	2253	if	st45	==1	&	t40	==1
replace vmt=	539	if	st46	==1	&	t40	==1
replace vmt=	7154	if	st47	==1	&	t40	==1
replace vmt=	4908	if	st48	==1	&	t40	==1
replace vmt=	1798	if	st49	==1	&	t40	==1
replace vmt=	5031	if	st50	==1	&	t40	==1
replace vmt=	747	if	st51	==1	&	t40	==1
replace vmt=	5181	if	st1	==1	&	t41	==1
replace vmt=	498	if	st2 	==1	&	t41	==1
replace vmt=	5602	if	st3	==1	&	t41	==1
replace vmt=	2959	if	st4	==1	&	t41	==1
replace vmt=	27362	if	st5	==1	&	t41	==1
replace vmt=	4132	if	st6	==1	&	t41	==1
replace vmt=	2874	if	st7	==1	&	t41	==1
replace vmt=	794	if	st8	==1	&	t41	==1
replace vmt=	339	if	st9	==1	&	t41	==1
replace vmt=	16641	if	st10	==1	&	t41	==1
replace vmt=	9594	if	st11	==1	&	t41	==1
replace vmt=	628	if	st12	==1	&	t41	==1
replace vmt=	1325	if	st13	==1	&	t41	==1
replace vmt=	9353	if	st14	==1	&	t41	==1
replace vmt=	6373	if	st15	==1	&	t41	==1
replace vmt=	2850	if	st16	==1	&	t41	==1
replace vmt=	2653	if	st17	==1	&	t41	==1
replace vmt=	4283	if	st18	==1	&	t41	==1
replace vmt=	3815	if	st19	==1	&	t41	==1
replace vmt=	1301	if	st20	==1	&	t41	==1
replace vmt=	5049	if	st21	==1	&	t41	==1
replace vmt=	4724	if	st22	==1	&	t41	==1
replace vmt=	8700	if	st23	==1	&	t41	==1
replace vmt=	5197	if	st24	==1	&	t41	==1
replace vmt=	3854	if	st25	==1	&	t41	==1
replace vmt=	6207	if	st26	==1	&	t41	==1
replace vmt=	924	if	st27	==1	&	t41	==1
replace vmt=	1777	if	st28	==1	&	t41	==1
replace vmt=	1861	if	st29	==1	&	t41	==1
replace vmt=	1106	if	st30	==1	&	t41	==1
replace vmt=	6322	if	st31	==1	&	t41	==1
replace vmt=	2298	if	st32	==1	&	t41	==1
replace vmt=	11983	if	st33	==1	&	t41	==1
replace vmt=	8850	if	st34	==1	&	t41	==1
replace vmt=	744	if	st35	==1	&	t41	==1
replace vmt=	9466	if	st36	==1	&	t41	==1
replace vmt=	4333	if	st37	==1	&	t41	==1
replace vmt=	2966	if	st38	==1	&	t41	==1
replace vmt=	9184	if	st39	==1	&	t41	==1
replace vmt=	753	if	st40	==1	&	t41	==1
replace vmt=	4421	if	st41	==1	&	t41	==1
replace vmt=	836	if	st42	==1	&	t41	==1
replace vmt=	5956	if	st43	==1	&	t41	==1
replace vmt=	20941	if	st44	==1	&	t41	==1
replace vmt=	2176	if	st45	==1	&	t41	==1
replace vmt=	646	if	st46	==1	&	t41	==1
replace vmt=	7327	if	st47	==1	&	t41	==1
replace vmt=	5052	if	st48	==1	&	t41	==1
replace vmt=	1889	if	st49	==1	&	t41	==1
replace vmt=	5291	if	st50	==1	&	t41	==1
replace vmt=	831	if	st51	==1	&	t41	==1
replace vmt=	5254	if	st1	==1	&	t42	==1
replace vmt=	471	if	st2 	==1	&	t42	==1
replace vmt=	5618	if	st3	==1	&	t42	==1
replace vmt=	3074	if	st4	==1	&	t42	==1
replace vmt=	28974	if	st5	==1	&	t42	==1
replace vmt=	3929	if	st6	==1	&	t42	==1
replace vmt=	2789	if	st7	==1	&	t42	==1
replace vmt=	879	if	st8	==1	&	t42	==1
replace vmt=	334	if	st9	==1	&	t42	==1
replace vmt=	16528	if	st10	==1	&	t42	==1
replace vmt=	8967	if	st11	==1	&	t42	==1
replace vmt=	832	if	st12	==1	&	t42	==1
replace vmt=	1382	if	st13	==1	&	t42	==1
replace vmt=	10399	if	st14	==1	&	t42	==1
replace vmt=	6472	if	st15	==1	&	t42	==1
replace vmt=	2861	if	st16	==1	&	t42	==1
replace vmt=	2639	if	st17	==1	&	t42	==1
replace vmt=	4249	if	st18	==1	&	t42	==1
replace vmt=	3878	if	st19	==1	&	t42	==1
replace vmt=	1316	if	st20	==1	&	t42	==1
replace vmt=	5082	if	st21	==1	&	t42	==1
replace vmt=	4857	if	st22	==1	&	t42	==1
replace vmt=	9080	if	st23	==1	&	t42	==1
replace vmt=	5303	if	st24	==1	&	t42	==1
replace vmt=	3975	if	st25	==1	&	t42	==1
replace vmt=	6168	if	st26	==1	&	t42	==1
replace vmt=	1105	if	st27	==1	&	t42	==1
replace vmt=	1824	if	st28	==1	&	t42	==1
replace vmt=	1661	if	st29	==1	&	t42	==1
replace vmt=	1179	if	st30	==1	&	t42	==1
replace vmt=	6525	if	st31	==1	&	t42	==1
replace vmt=	2195	if	st32	==1	&	t42	==1
replace vmt=	11710	if	st33	==1	&	t42	==1
replace vmt=	8896	if	st34	==1	&	t42	==1
replace vmt=	799	if	st35	==1	&	t42	==1
replace vmt=	9607	if	st36	==1	&	t42	==1
replace vmt=	4109	if	st37	==1	&	t42	==1
replace vmt=	3045	if	st38	==1	&	t42	==1
replace vmt=	9447	if	st39	==1	&	t42	==1
replace vmt=	745	if	st40	==1	&	t42	==1
replace vmt=	4371	if	st41	==1	&	t42	==1
replace vmt=	888	if	st42	==1	&	t42	==1
replace vmt=	6214	if	st43	==1	&	t42	==1
replace vmt=	20240	if	st44	==1	&	t42	==1
replace vmt=	2182	if	st45	==1	&	t42	==1
replace vmt=	624	if	st46	==1	&	t42	==1
replace vmt=	7294	if	st47	==1	&	t42	==1
replace vmt=	5228	if	st48	==1	&	t42	==1
replace vmt=	1923	if	st49	==1	&	t42	==1
replace vmt=	5229	if	st50	==1	&	t42	==1
replace vmt=	892	if	st51	==1	&	t42	==1
replace vmt=	5389	if	st1	==1	&	t43	==1
replace vmt=	501	if	st2 	==1	&	t43	==1
replace vmt=	5044	if	st3	==1	&	t43	==1
replace vmt=	3226	if	st4	==1	&	t43	==1
replace vmt=	29041	if	st5	==1	&	t43	==1
replace vmt=	4124	if	st6	==1	&	t43	==1
replace vmt=	2925	if	st7	==1	&	t43	==1
replace vmt=	924	if	st8	==1	&	t43	==1
replace vmt=	242	if	st9	==1	&	t43	==1
replace vmt=	16671	if	st10	==1	&	t43	==1
replace vmt=	9281	if	st11	==1	&	t43	==1
replace vmt=	877	if	st12	==1	&	t43	==1
replace vmt=	1524	if	st13	==1	&	t43	==1
replace vmt=	9619	if	st14	==1	&	t43	==1
replace vmt=	6687	if	st15	==1	&	t43	==1
replace vmt=	2903	if	st16	==1	&	t43	==1
replace vmt=	2793	if	st17	==1	&	t43	==1
replace vmt=	4373	if	st18	==1	&	t43	==1
replace vmt=	3928	if	st19	==1	&	t43	==1
replace vmt=	1394	if	st20	==1	&	t43	==1
replace vmt=	5011	if	st21	==1	&	t43	==1
replace vmt=	5124	if	st22	==1	&	t43	==1
replace vmt=	9195	if	st23	==1	&	t43	==1
replace vmt=	5096	if	st24	==1	&	t43	==1
replace vmt=	4165	if	st25	==1	&	t43	==1
replace vmt=	6480	if	st26	==1	&	t43	==1
replace vmt=	1341	if	st27	==1	&	t43	==1
replace vmt=	1904	if	st28	==1	&	t43	==1
replace vmt=	1746	if	st29	==1	&	t43	==1
replace vmt=	1257	if	st30	==1	&	t43	==1
replace vmt=	6267	if	st31	==1	&	t43	==1
replace vmt=	2447	if	st32	==1	&	t43	==1
replace vmt=	12064	if	st33	==1	&	t43	==1
replace vmt=	9238	if	st34	==1	&	t43	==1
replace vmt=	884	if	st35	==1	&	t43	==1
replace vmt=	9999	if	st36	==1	&	t43	==1
replace vmt=	4455	if	st37	==1	&	t43	==1
replace vmt=	3356	if	st38	==1	&	t43	==1
replace vmt=	9940	if	st39	==1	&	t43	==1
replace vmt=	815	if	st40	==1	&	t43	==1
replace vmt=	4569	if	st41	==1	&	t43	==1
replace vmt=	1016	if	st42	==1	&	t43	==1
replace vmt=	6560	if	st43	==1	&	t43	==1
replace vmt=	20728	if	st44	==1	&	t43	==1
replace vmt=	2391	if	st45	==1	&	t43	==1
replace vmt=	751	if	st46	==1	&	t43	==1
replace vmt=	7576	if	st47	==1	&	t43	==1
replace vmt=	5676	if	st48	==1	&	t43	==1
replace vmt=	1934	if	st49	==1	&	t43	==1
replace vmt=	5525	if	st50	==1	&	t43	==1
replace vmt=	994	if	st51	==1	&	t43	==1
replace vmt=	5449	if	st1	==1	&	t44	==1
replace vmt=	486	if	st2 	==1	&	t44	==1
replace vmt=	4475	if	st3	==1	&	t44	==1
replace vmt=	3080	if	st4	==1	&	t44	==1
replace vmt=	29755	if	st5	==1	&	t44	==1
replace vmt=	4499	if	st6	==1	&	t44	==1
replace vmt=	2901	if	st7	==1	&	t44	==1
replace vmt=	889	if	st8	==1	&	t44	==1
replace vmt=	357	if	st9	==1	&	t44	==1
replace vmt=	16479	if	st10	==1	&	t44	==1
replace vmt=	8929	if	st11	==1	&	t44	==1
replace vmt=	835	if	st12	==1	&	t44	==1
replace vmt=	1511	if	st13	==1	&	t44	==1
replace vmt=	9314	if	st14	==1	&	t44	==1
replace vmt=	6121	if	st15	==1	&	t44	==1
replace vmt=	2828	if	st16	==1	&	t44	==1
replace vmt=	2750	if	st17	==1	&	t44	==1
replace vmt=	4200	if	st18	==1	&	t44	==1
replace vmt=	4221	if	st19	==1	&	t44	==1
replace vmt=	1326	if	st20	==1	&	t44	==1
replace vmt=	5244	if	st21	==1	&	t44	==1
replace vmt=	4855	if	st22	==1	&	t44	==1
replace vmt=	9043	if	st23	==1	&	t44	==1
replace vmt=	5237	if	st24	==1	&	t44	==1
replace vmt=	3774	if	st25	==1	&	t44	==1
replace vmt=	6412	if	st26	==1	&	t44	==1
replace vmt=	1296	if	st27	==1	&	t44	==1
replace vmt=	1900	if	st28	==1	&	t44	==1
replace vmt=	1720	if	st29	==1	&	t44	==1
replace vmt=	1265	if	st30	==1	&	t44	==1
replace vmt=	6277	if	st31	==1	&	t44	==1
replace vmt=	2317	if	st32	==1	&	t44	==1
replace vmt=	12449	if	st33	==1	&	t44	==1
replace vmt=	9023	if	st34	==1	&	t44	==1
replace vmt=	828	if	st35	==1	&	t44	==1
replace vmt=	9558	if	st36	==1	&	t44	==1
replace vmt=	4609	if	st37	==1	&	t44	==1
replace vmt=	3386	if	st38	==1	&	t44	==1
replace vmt=	10049	if	st39	==1	&	t44	==1
replace vmt=	864	if	st40	==1	&	t44	==1
replace vmt=	4320	if	st41	==1	&	t44	==1
replace vmt=	946	if	st42	==1	&	t44	==1
replace vmt=	6145	if	st43	==1	&	t44	==1
replace vmt=	21030	if	st44	==1	&	t44	==1
replace vmt=	2506	if	st45	==1	&	t44	==1
replace vmt=	728	if	st46	==1	&	t44	==1
replace vmt=	7417	if	st47	==1	&	t44	==1
replace vmt=	5569	if	st48	==1	&	t44	==1
replace vmt=	1830	if	st49	==1	&	t44	==1
replace vmt=	5514	if	st50	==1	&	t44	==1
replace vmt=	960	if	st51	==1	&	t44	==1
replace vmt=	4800	if	st1	==1	&	t45	==1
replace vmt=	429	if	st2 	==1	&	t45	==1
replace vmt=	4527	if	st3	==1	&	t45	==1
replace vmt=	2709	if	st4	==1	&	t45	==1
replace vmt=	24258	if	st5	==1	&	t45	==1
replace vmt=	4107	if	st6	==1	&	t45	==1
replace vmt=	2712	if	st7	==1	&	t45	==1
replace vmt=	829	if	st8	==1	&	t45	==1
replace vmt=	326	if	st9	==1	&	t45	==1
replace vmt=	15782	if	st10	==1	&	t45	==1
replace vmt=	8494	if	st11	==1	&	t45	==1
replace vmt=	1055	if	st12	==1	&	t45	==1
replace vmt=	1369	if	st13	==1	&	t45	==1
replace vmt=	8952	if	st14	==1	&	t45	==1
replace vmt=	6008	if	st15	==1	&	t45	==1
replace vmt=	2786	if	st16	==1	&	t45	==1
replace vmt=	2539	if	st17	==1	&	t45	==1
replace vmt=	3997	if	st18	==1	&	t45	==1
replace vmt=	3481	if	st19	==1	&	t45	==1
replace vmt=	1215	if	st20	==1	&	t45	==1
replace vmt=	4451	if	st21	==1	&	t45	==1
replace vmt=	4448	if	st22	==1	&	t45	==1
replace vmt=	8327	if	st23	==1	&	t45	==1
replace vmt=	4948	if	st24	==1	&	t45	==1
replace vmt=	3544	if	st25	==1	&	t45	==1
replace vmt=	6426	if	st26	==1	&	t45	==1
replace vmt=	1031	if	st27	==1	&	t45	==1
replace vmt=	1743	if	st28	==1	&	t45	==1
replace vmt=	1648	if	st29	==1	&	t45	==1
replace vmt=	1110	if	st30	==1	&	t45	==1
replace vmt=	6587	if	st31	==1	&	t45	==1
replace vmt=	2164	if	st32	==1	&	t45	==1
replace vmt=	11539	if	st33	==1	&	t45	==1
replace vmt=	8560	if	st34	==1	&	t45	==1
replace vmt=	705	if	st35	==1	&	t45	==1
replace vmt=	9178	if	st36	==1	&	t45	==1
replace vmt=	4157	if	st37	==1	&	t45	==1
replace vmt=	2999	if	st38	==1	&	t45	==1
replace vmt=	9267	if	st39	==1	&	t45	==1
replace vmt=	1052	if	st40	==1	&	t45	==1
replace vmt=	4118	if	st41	==1	&	t45	==1
replace vmt=	830		if	st42	==1	&	t45	==1
replace vmt=	5879	if	st43	==1	&	t45	==1
replace vmt=	20023	if	st44	==1	&	t45	==1
replace vmt=	2218	if	st45	==1	&	t45	==1
replace vmt=	644		if	st46	==1	&	t45	==1
replace vmt=	6910	if	st47	==1	&	t45	==1
replace vmt=	5188	if	st48	==1	&	t45	==1
replace vmt=	1897	if	st49	==1	&	t45	==1
replace vmt=	4950	if	st50	==1	&	t45	==1
replace vmt=	875		if	st51	==1	&	t45	==1
replace vmt=	4973	if	st1	==1	&	t46	==1
replace vmt=	444		if	st2 	==1	&	t46	==1
replace vmt=	4907	if	st3	==1	&	t46	==1
replace vmt=	2880	if	st4	==1	&	t46	==1
replace vmt=	27964	if	st5	==1	&	t46	==1
replace vmt=	4191	if	st6	==1	&	t46	==1
replace vmt=	2885	if	st7	==1	&	t46	==1
replace vmt=	773		if	st8	==1	&	t46	==1
replace vmt=	333		if	st9	==1	&	t46	==1
replace vmt=	16665	if	st10	==1	&	t46	==1
replace vmt=	9449	if	st11	==1	&	t46	==1
replace vmt=	1148	if	st12	==1	&	t46	==1
replace vmt=	1348	if	st13	==1	&	t46	==1
replace vmt=	9617	if	st14	==1	&	t46	==1
replace vmt=	6604	if	st15	==1	&	t46	==1
replace vmt=	2959	if	st16	==1	&	t46	==1
replace vmt=	2603	if	st17	==1	&	t46	==1
replace vmt=	4217	if	st18	==1	&	t46	==1
replace vmt=	3865	if	st19	==1	&	t46	==1
replace vmt=	1253	if	st20	==1	&	t46	==1
replace vmt=	5034	if	st21	==1	&	t46	==1
replace vmt=	4944	if	st22	==1	&	t46	==1
replace vmt=	8686	if	st23	==1	&	t46	==1
replace vmt=	5143	if	st24	==1	&	t46	==1
replace vmt=	3780	if	st25	==1	&	t46	==1
replace vmt=	5725	if	st26	==1	&	t46	==1
replace vmt=	957		if	st27	==1	&	t46	==1
replace vmt=	1843	if	st28	==1	&	t46	==1
replace vmt=	1741	if	st29	==1	&	t46	==1
replace vmt=	1140	if	st30	==1	&	t46	==1
replace vmt=	6488	if	st31	==1	&	t46	==1
replace vmt=	2414	if	st32	==1	&	t46	==1
replace vmt=	11381	if	st33	==1	&	t46	==1
replace vmt=	9265	if	st34	==1	&	t46	==1
replace vmt=	837		if	st35	==1	&	t46	==1
replace vmt=	9491	if	st36	==1	&	t46	==1
replace vmt=	4163	if	st37	==1	&	t46	==1
replace vmt=	2914	if	st38	==1	&	t46	==1
replace vmt=	9480	if	st39	==1	&	t46	==1
replace vmt=	590		if	st40	==1	&	t46	==1
replace vmt=	4144	if	st41	==1	&	t46	==1
replace vmt=	803		if	st42	==1	&	t46	==1
replace vmt=	5886	if	st43	==1	&	t46	==1
replace vmt=	20980	if	st44	==1	&	t46	==1
replace vmt=	2203	if	st45	==1	&	t46	==1
replace vmt=	634		if	st46	==1	&	t46	==1
replace vmt=	7152	if	st47	==1	&	t46	==1
replace vmt=	4845	if	st48	==1	&	t46	==1
replace vmt=	1912	if	st49	==1	&	t46	==1
replace vmt=	5064	if	st50	==1	&	t46	==1
replace vmt=	852		if	st51	==1	&	t46	==1
replace vmt=	4615	if	st1	==1	&	t47	==1
replace vmt=	356		if	st2 	==1	&	t47	==1
replace vmt=	4769	if	st3	==1	&	t47	==1
replace vmt=	2645	if	st4	==1	&	t47	==1
replace vmt=	29073	if	st5	==1	&	t47	==1
replace vmt=	3573	if	st6	==1	&	t47	==1
replace vmt=	2679	if	st7	==1	&	t47	==1
replace vmt=	704		if	st8	==1	&	t47	==1
replace vmt=	307		if	st9	==1	&	t47	==1
replace vmt=	16260	if	st10	==1	&	t47	==1
replace vmt=	8414	if	st11	==1	&	t47	==1
replace vmt=	823		if	st12	==1	&	t47	==1
replace vmt=	1169	if	st13	==1	&	t47	==1
replace vmt=	8077	if	st14	==1	&	t47	==1
replace vmt=	5754	if	st15	==1	&	t47	==1
replace vmt=	2498	if	st16	==1	&	t47	==1
replace vmt=	2528	if	st17	==1	&	t47	==1
replace vmt=	3867	if	st18	==1	&	t47	==1
replace vmt=	3718	if	st19	==1	&	t47	==1
replace vmt=	1135	if	st20	==1	&	t47	==1
replace vmt=	4620	if	st21	==1	&	t47	==1
replace vmt=	4525	if	st22	==1	&	t47	==1
replace vmt=	7722	if	st23	==1	&	t47	==1
replace vmt=	4679	if	st24	==1	&	t47	==1
replace vmt=	3576	if	st25	==1	&	t47	==1
replace vmt=	5506	if	st26	==1	&	t47	==1
replace vmt=	860		if	st27	==1	&	t47	==1
replace vmt=	1640	if	st28	==1	&	t47	==1
replace vmt=	1640	if	st29	==1	&	t47	==1
replace vmt=	995		if	st30	==1	&	t47	==1
replace vmt=	6392	if	st31	==1	&	t47	==1
replace vmt=	2107	if	st32	==1	&	t47	==1
replace vmt=	10554	if	st33	==1	&	t47	==1
replace vmt=	8191	if	st34	==1	&	t47	==1
replace vmt=	686		if	st35	==1	&	t47	==1
replace vmt=	9101	if	st36	==1	&	t47	==1
replace vmt=	4060	if	st37	==1	&	t47	==1
replace vmt=	2541	if	st38	==1	&	t47	==1
replace vmt=	8615	if	st39	==1	&	t47	==1
replace vmt=	592		if	st40	==1	&	t47	==1
replace vmt=	3905	if	st41	==1	&	t47	==1
replace vmt=	702		if	st42	==1	&	t47	==1
replace vmt=	5382	if	st43	==1	&	t47	==1
replace vmt=	19669	if	st44	==1	&	t47	==1
replace vmt=	1999	if	st45	==1	&	t47	==1
replace vmt=	522		if	st46	==1	&	t47	==1
replace vmt=	6804	if	st47	==1	&	t47	==1
replace vmt=	4191	if	st48	==1	&	t47	==1
replace vmt=	1703	if	st49	==1	&	t47	==1
replace vmt=	4636	if	st50	==1	&	t47	==1
replace vmt=	737		if	st51	==1	&	t47	==1
replace vmt=	4425	if	st1	==1	&	t48	==1
replace vmt=	352		if	st2 	==1	&	t48	==1
replace vmt=	5570	if	st3	==1	&	t48	==1
replace vmt=	2784	if	st4	==1	&	t48	==1
replace vmt=	28695	if	st5	==1	&	t48	==1
replace vmt=	3882	if	st6	==1	&	t48	==1
replace vmt=	2594	if	st7	==1	&	t48	==1
replace vmt=	712		if	st8	==1	&	t48	==1
replace vmt=	324		if	st9	==1	&	t48	==1
replace vmt=	16256	if	st10	==1	&	t48	==1
replace vmt=	8867	if	st11	==1	&	t48	==1
replace vmt=	859		if	st12	==1	&	t48	==1
replace vmt=	1151	if	st13	==1	&	t48	==1
replace vmt=	8394	if	st14	==1	&	t48	==1
replace vmt=	6423	if	st15	==1	&	t48	==1
replace vmt=	2362	if	st16	==1	&	t48	==1
replace vmt=	2321	if	st17	==1	&	t48	==1
replace vmt=	3681	if	st18	==1	&	t48	==1
replace vmt=	3349	if	st19	==1	&	t48	==1
replace vmt=	1138	if	st20	==1	&	t48	==1
replace vmt=	4435	if	st21	==1	&	t48	==1
replace vmt=	4778	if	st22	==1	&	t48	==1
replace vmt=	7861	if	st23	==1	&	t48	==1
replace vmt=	4427	if	st24	==1	&	t48	==1
replace vmt=	2958	if	st25	==1	&	t48	==1
replace vmt=	5664	if	st26	==1	&	t48	==1
replace vmt=	789		if	st27	==1	&	t48	==1
replace vmt=	1554	if	st28	==1	&	t48	==1
replace vmt=	1841	if	st29	==1	&	t48	==1
replace vmt=	1055	if	st30	==1	&	t48	==1
replace vmt=	6305	if	st31	==1	&	t48	==1
replace vmt=	2164	if	st32	==1	&	t48	==1
replace vmt=	11204	if	st33	==1	&	t48	==1
replace vmt=	9848	if	st34	==1	&	t48	==1
replace vmt=	665		if	st35	==1	&	t48	==1
replace vmt=	8820	if	st36	==1	&	t48	==1
replace vmt=	3600	if	st37	==1	&	t48	==1
replace vmt=	2630	if	st38	==1	&	t48	==1
replace vmt=	9389	if	st39	==1	&	t48	==1
replace vmt=	650		if	st40	==1	&	t48	==1
replace vmt=	3816	if	st41	==1	&	t48	==1
replace vmt=	768		if	st42	==1	&	t48	==1
replace vmt=	5858	if	st43	==1	&	t48	==1
replace vmt=	18944	if	st44	==1	&	t48	==1
replace vmt=	2034	if	st45	==1	&	t48	==1
replace vmt=	583		if	st46	==1	&	t48	==1
replace vmt=	6345	if	st47	==1	&	t48	==1
replace vmt=	4246	if	st48	==1	&	t48	==1
replace vmt=	1517	if	st49	==1	&	t48	==1
replace vmt=	4516	if	st50	==1	&	t48	==1
replace vmt=	738		if	st51	==1	&	t48	==1


gen rgastax=gastax/cpi
gen lrgastax=ln(rgastax)









*Generating Difference-in-Differences variable
*---------------------------------------------------
generate txmsban=0
replace txmsban=1 if st4==1 & time>33
replace txmsban=1 if st5==1 & time>24
replace txmsban=1 if st6==1 & time>35
replace txmsban=1 if st15==1 & time>30
replace txmsban=1 if st19==1 & time>18
replace txmsban=1 if st21==1 & time>33
replace txmsban=1 if st24==1 & time>19
replace txmsban=1 if st26==1 & time>31
replace txmsban=1 if st31==1 & time>14
replace txmsban=1 if st33==1 & time>34
replace txmsban=1 if st34==1 & time>35
replace txmsban=1 if st40==1 & time>34
replace txmsban=1 if st43==1 & time>30
replace txmsban=1 if st45==1 & time>28
replace txmsban=1 if st47==1 & time>30
replace txmsban=1 if st48==1 & time>12

replace txmsban=1 if st7==1 & time>45
replace txmsban=1 if st11==1 & time>42
replace txmsban=1 if st14==1 & time>36
replace txmsban=1 if st22==1 & time>45
replace txmsban=1 if st23==1 & time>42
replace txmsban=1 if st28==1 & time>42
replace txmsban=1 if st30==1 & time>36

replace txmsban=1 if st38==1 & time>36
replace txmsban=1 if st46==1 & time>41
replace txmsban=1 if st50==1 & time>47
replace txmsban=1 if st51==1 & time>42













sort state time
collapse pop rgastax permale unemp vmt txmsban month year, by (state time)
tab state, gen(st)
keep if state~=2 & state~=11
sort state time
save controls, replace










clear

# use person07
### EDIT BY Donna
use person07.dta
collapse (max) PER_TYP PER_NO ROAD_FNC, by(ST_CASE)
sort ST_CASE
save person07c, replace
clear
use vehicle07
collapse (max) ocupants, by(ST_CASE)
sort ST_CASE
merge using accident07
drop _merge
merge using person07c
rename VE_FORMS ve_forms
rename PER_TYP per_typ
save full07, replace


clear
use person08
collapse (max) PER_TYP PER_NO ROAD_FNC, by(ST_CASE)
sort ST_CASE
save person08c, replace
clear
use vehicle08
collapse (max) ocupants, by(ST_CASE)
sort ST_CASE
merge using accident08
drop _merge
merge using person08c
rename VE_FORMS ve_forms
rename PER_TYP per_typ
save full08, replace



clear
use person09
collapse (max) per_typ per_no road_fnc, by(st_case)
sort st_case
save person09c, replace
clear
use vehicle09
collapse (max) ocupants=numoccs, by(st_case)
sort st_case
merge using accident09
drop _merge
merge using person09c
save full09, replace

clear
use person10
collapse (max) per_typ per_no road_fnc, by(st_case)
sort st_case
save person10c, replace
clear
use vehicle10
collapse (max) ocupants=numoccs, by(st_case)
sort st_case
merge using accident10
drop _merge
merge using person10c
save full10, replace

append using full09
append using full08
append using full07


* Single vehicle-Single occupant crashes
*--------------------------------------------
gen accidentsvso = 0
replace accidentsvso = 1 if  ve_forms==1 & ocupants==1 & per_typ==1 


* multiple vehicle multiple occupant

gen accidentmv = 0
replace accidentmv = 1 if  ve_forms>1 


* all accidents

gen accident = 1

* Other

gen accidentother = accidentsvso==0




tab month, gen(mon)
tab state, gen(st)
tab year, gen(yr)
rename month mon
generate time=0
replace time=1 if mon==1 & year==2007
replace time=2 if mon==2 & year==2007
replace time=3 if mon==3 & year==2007
replace time=4 if mon==4 & year==2007
replace time=5 if mon==5 & year==2007
replace time=6 if mon==6 & year==2007
replace time=7 if mon==7 & year==2007
replace time=8 if mon==8 & year==2007
replace time=9 if mon==9 & year==2007
replace time=10 if mon==10 & year==2007
replace time=11 if mon==11 & year==2007
replace time=12 if mon==12 & year==2007
replace time=13 if mon==1 & year==2008
replace time=14 if mon==2 & year==2008
replace time=15 if mon==3 & year==2008
replace time=16 if mon==4 & year==2008
replace time=17 if mon==5 & year==2008
replace time=18 if mon==6 & year==2008
replace time=19 if mon==7 & year==2008
replace time=20 if mon==8 & year==2008
replace time=21 if mon==9 & year==2008
replace time=22 if mon==10 & year==2008
replace time=23 if mon==11 & year==2008
replace time=24 if mon==12 & year==2008
replace time=25 if mon==1 & year==2009
replace time=26 if mon==2 & year==2009
replace time=27 if mon==3 & year==2009
replace time=28 if mon==4 & year==2009
replace time=29 if mon==5 & year==2009
replace time=30 if mon==6 & year==2009
replace time=31 if mon==7 & year==2009
replace time=32 if mon==8 & year==2009
replace time=33 if mon==9 & year==2009
replace time=34 if mon==10 & year==2009
replace time=35 if mon==11 & year==2009
replace time=36 if mon==12 & year==2009
replace time=37 if mon==1 & year==2010
replace time=38 if mon==2 & year==2010
replace time=39 if mon==3 & year==2010
replace time=40 if mon==4 & year==2010
replace time=41 if mon==5 & year==2010
replace time=42 if mon==6 & year==2010
replace time=43 if mon==7 & year==2010
replace time=44 if mon==8 & year==2010
replace time=45 if mon==9 & year==2010
replace time=46 if mon==10 & year==2010
replace time=47 if mon==11 & year==2010
replace time=48 if mon==12 & year==2010


collapse (sum) accident accidentsvso accidentmv accidentother, by(state time)


generate year=0
replace year=2007 if time<13
replace year=2008 if time>12 & time<25
replace year=2009 if time>24 & time<37
replace year=2010 if time>36


sort state time
merge state time using controls

replace accident = 0 if accident==.
replace accidentsvso = 0 if accidentsvso==.
replace accidentmv = 0 if accidentmv==.
replace accidentother = 0 if accidentother==. 


gen stb1 = st1* txmsban 
gen stb2 = st2*txmsban  
gen stb3 = st3*txmsban  
gen stb4 = st4*txmsban  
gen stb5 = st5*txmsban  
gen stb6 = st6*txmsban  

gen stb7 = st7*txmsban  
gen stb8 = st8*txmsban  
gen stb9 = st9*txmsban  
gen stb10 = st10*txmsban  
gen stb11 = st11*txmsban  
gen stb12 = st12*txmsban  

gen stb13 = st13*txmsban  
gen stb14 = st14*txmsban  
gen stb15 = st15*txmsban  
gen stb16 = st16*txmsban  
gen stb17 = st17*txmsban  
gen stb18 = st18*txmsban  

gen stb19 = st19*txmsban  
gen stb20 = st20*txmsban  
gen stb21 = st21*txmsban  
gen stb22 = st22*txmsban  
gen stb23 = st23*txmsban  
gen stb24 = st24*txmsban  

gen stb25 = st25*txmsban  
gen stb26 = st26*txmsban  
gen stb27 = st27*txmsban  
gen stb28 = st28*txmsban  
gen stb29 = st29*txmsban  
gen stb30 = st30*txmsban  

gen stb31 = st31*txmsban  
gen stb32 = st32*txmsban  
gen stb33 = st33*txmsban  
gen stb34 = st34*txmsban  
gen stb35 = st35*txmsban  
gen stb36 = st36*txmsban  

gen stb37 = st37*txmsban  
gen stb38 = st38*txmsban  
gen stb39 = st39*txmsban  
gen stb40 = st40*txmsban  
gen stb41 = st41*txmsban  
gen stb42 = st42*txmsban  

gen stb43 = st43*txmsban  
gen stb44 = st44*txmsban  
gen stb45 = st45*txmsban  
gen stb46 = st46*txmsban  
gen stb47 = st47*txmsban  
gen stb48 = st48*txmsban  

gen stb49 = st49*txmsban  
gen stb50 = st50*txmsban  
gen stb51 = st51*txmsban  





*Hand Held ban
*---------------------------
gen HHBAN=0
replace HHBAN=1 if st5==1 | st31==1 | st33==1|st7==1


*Secondary
gen second = st28==1|st33==1|st47==1|st48==1

* limited age
gen agelimit = st15==1|st26==1

* balanced

gen balanced = st7~=1 & st11~=1 & st22~=1 & st50~=1



generate laccident=log(accident)
generate lpop=log(pop)
gen laccident2=ln(accident+1)
gen laccidentsvso2=ln(accidentsvso+1)
gen laccidentother2=ln(accidentother+1)
gen laccidentmv2=ln(accidentother+1)
gen lacc2vmt=laccidentsvso2-log(vmt)
gen lacc2vmta=laccident2-log(vmt)
gen lacc2vmto=laccidentmv2-log(vmt)
gen accvmt = accidentsvso/vmt
gen lvmt = log(vmt)



tab time,gen(t)
tab month,gen(mon)




*controls

gen lunemp = ln(unemp)
gen permale2 = permale *100
gen lrgastax = ln(rgastax)



gen stt1 = st1* time 
gen stt2 = st2*time  
gen stt3 = st3*time  
gen stt4 = st4*time  
gen stt5 = st5*time  
gen stt6 = st6*time  

gen stt7 = st7*time  
gen stt8 = st8*time  
gen stt9 = st9*time  
gen stt10 = st10*time  
gen stt11 = st11*time  
gen stt12 = st12*time  

gen stt13 = st13*time  
gen stt14 = st14*time  
gen stt15 = st15*time  
gen stt16 = st16*time  
gen stt17 = st17*time  
gen stt18 = st18*time  

gen stt19 = st19*time  
gen stt20 = st20*time  
gen stt21 = st21*time  
gen stt22 = st22*time  
gen stt23 = st23*time  
gen stt24 = st24*time  

gen stt25 = st25*time  
gen stt26 = st26*time  
gen stt27 = st27*time  
gen stt28 = st28*time  
gen stt29 = st29*time  
gen stt30 = st30*time  

gen stt31 = st31*time  
gen stt32 = st32*time  
gen stt33 = st33*time  
gen stt34 = st34*time  
gen stt35 = st35*time  
gen stt36 = st36*time  

gen stt37 = st37*time  
gen stt38 = st38*time  
gen stt39 = st39*time  
gen stt40 = st40*time  
gen stt41 = st41*time  
gen stt42 = st42*time  

gen stt43 = st43*time  
gen stt44 = st44*time  
gen stt45 = st45*time  
gen stt46 = st46*time  
gen stt47 = st47*time  
gen stt48 = st48*time  

gen stt49 = st49*time  
gen stt50 = st50*time  
gen stt51 = st51*time  



gen lead11= ((time==23 & st4==1) | (time==14 & st5==1 )| (time==25 & st6==1)  | (time==20 & st15==1) | (time==8 & st19==1) | (time==23 & st21==1) | (time==9 & st24==1) | (time==21 & st26==1) | (time==4 & st31==1) | (time==24 & st33==1) | (time==25 & st34==1) | (time==24 & st40==1) | (time==20 & st43==1) | (time==18 & st45==1) | (time==20 & st47==1) | (time==2 & st48==1) |(time==37 & st50==1)| (time==35 & st7==1)| (time==35 & st22==1)| (time==32 & st11==1)| (time==32 & st23==1)|(time==32 & st28==1)|(time==32 & st51==1)|(time==31 & st46==1)|(time==26 & st14==1)|(time==26 & st30==1)|(time==26 & st38==1))


gen lead10= ((time==24 & st4==1) | (time==15 & st5==1 )| (time==26 & st6==1)  | (time==21 & st15==1) | (time==9 & st19==1) | (time==24 & st21==1) | (time==10 & st24==1) | (time==22 & st26==1) | (time==5 & st31==1) | (time==25 & st33==1) | (time==26 & st34==1) | (time==25 & st40==1) | (time==21 & st43==1) | (time==19 & st45==1) | (time==21 & st47==1) | (time==3 & st48==1) |(time==38 & st50==1)| (time==36 & st7==1)| (time==36 & st22==1)| (time==33 & st11==1)| (time==33 & st23==1)|(time==33 & st28==1)|(time==33 & st51==1)|(time==32 & st46==1)|(time==27 & st14==1)|(time==27 & st30==1)|(time==27 & st38==1))



gen lead9= ((time==25 & st4==1) | (time==16 & st5==1 )| (time==27 & st6==1)  | (time==22 & st15==1) | (time==10 & st19==1) | (time==25 & st21==1) | (time==11 & st24==1) | (time==23 & st26==1) | (time==6 & st31==1) | (time==26 & st33==1) | (time==27 & st34==1) | (time==26 & st40==1) | (time==22 & st43==1) | (time==20 & st45==1) | (time==22 & st47==1) | (time==4 & st48==1) |(time==39 & st50==1)| (time==37 & st7==1)| (time==37 & st22==1)| (time==34 & st11==1)| (time==34 & st23==1)|(time==34 & st28==1)|(time==34 & st51==1)|(time==33 & st46==1)|(time==28 & st14==1)|(time==28 & st30==1)|(time==28 & st38==1))


gen lead8= ((time==26 & st4==1) | (time==17 & st5==1 )| (time==28 & st6==1)  | (time==23 & st15==1) | (time==11 & st19==1) | (time==26 & st21==1) | (time==12 & st24==1) | (time==24 & st26==1) | (time==7 & st31==1) | (time==27 & st33==1) | (time==28 & st34==1) | (time==27 & st40==1) | (time==23 & st43==1) | (time==21 & st45==1) | (time==23 & st47==1) | (time==5 & st48==1) |(time==40 & st50==1)| (time==38 & st7==1)| (time==38 & st22==1)| (time==35 & st11==1)| (time==35 & st23==1)|(time==35 & st28==1)|(time==35 & st51==1)|(time==34 & st46==1)|(time==29 & st14==1)|(time==29 & st30==1)|(time==29 & st38==1))


gen lead7= ((time==27 & st4==1) | (time==18 & st5==1 )| (time==29 & st6==1)  | (time==24 & st15==1) | (time==12 & st19==1) | (time==27 & st21==1) | (time==13 & st24==1) | (time==25 & st26==1) | (time==8 & st31==1) | (time==28 & st33==1) | (time==29 & st34==1) | (time==28 & st40==1) | (time==24 & st43==1) | (time==22 & st45==1) | (time==24 & st47==1) | (time==6 & st48==1) |(time==41 & st50==1)| (time==39 & st7==1)| (time==39 & st22==1)| (time==36 & st11==1)| (time==36 & st23==1)|(time==36 & st28==1)|(time==36 & st51==1)|(time==35 & st46==1)|(time==30 & st14==1)|(time==30 & st30==1)|(time==30 & st38==1))


gen lead6= ((time==28 & st4==1) | (time==19 & st5==1 )| (time==30 & st6==1)  | (time==25 & st15==1) | (time==13 & st19==1) | (time==28 & st21==1) | (time==14 & st24==1) | (time==26 & st26==1) | (time==9 & st31==1) | (time==29 & st33==1) | (time==30 & st34==1) | (time==29 & st40==1) | (time==25 & st43==1) | (time==23 & st45==1) | (time==25 & st47==1) | (time==7 & st48==1) |(time==42 & st50==1)| (time==40 & st7==1)| (time==40 & st22==1)| (time==37 & st11==1)| (time==37 & st23==1)|(time==37 & st28==1)|(time==37 & st51==1)|(time==36 & st46==1)|(time==31 & st14==1)|(time==31 & st30==1)|(time==31 & st38==1))

gen lead5= ((time==29 & st4==1) | (time==20 & st5==1)| (time==31 & st6==1)  | (time==26 & st15==1) | (time==14 & st19==1) | (time==29 & st21==1) | (time==15 & st24==1) | (time==27 & st26==1) | (time==10 & st31==1) | (time==30 & st33==1) | (time==31 & st34==1) | (time==30 & st40==1) | (time==26 & st43==1) | (time==24 & st45==1) | (time==26 & st47==1) | (time==8 & st48==1) |(time==43 & st50==1)| (time==41 & st7==1)| (time==41 & st22==1)| (time==38 & st11==1)| (time==38 & st23==1)|(time==38 & st28==1)|(time==38 & st51==1)|(time==37 & st46==1)|(time==32 & st14==1)|(time==32 & st30==1)|(time==32 & st38==1))

gen lead4= ((time==30 & st4==1) | (time==21 & st5==1 )| (time==32 & st6==1)  | (time==27 & st15==1) | (time==15 & st19==1) | (time==30 & st21==1) | (time==16 & st24==1) | (time==28 & st26==1) | (time==11 & st31==1) | (time==31 & st33==1) | (time==32 & st34==1) | (time==31 & st40==1) | (time==27 & st43==1) | (time==25 & st45==1) | (time==27 & st47==1) | (time==9 & st48==1) |(time==44 & st50==1)| (time==42 & st7==1)| (time==42 & st22==1)| (time==39 & st11==1)| (time==39 & st23==1)|(time==39 & st28==1)|(time==39 & st51==1)|(time==38 & st46==1)|(time==33 & st14==1)|(time==33 & st30==1)|(time==33 & st38==1))

gen lead3= ((time==31 & st4==1) | (time==22 & st5==1 )| (time==33 & st6==1)  | (time==28 & st15==1) | (time==16 & st19==1) | (time==31 & st21==1) | (time==17 & st24==1) | (time==29 & st26==1) | (time==12 & st31==1) | (time==32 & st33==1) | (time==33 & st34==1) | (time==32 & st40==1) | (time==28 & st43==1) | (time==26 & st45==1) | (time==28 & st47==1) | (time==10 & st48==1)|(time==45 & st50==1)| (time==43 & st7==1)| (time==43 & st22==1)| (time==40 & st11==1)| (time==40 & st23==1)|(time==40 & st28==1)|(time==40 & st51==1)|(time==39 & st46==1)|(time==34 & st14==1)|(time==34 & st30==1)|(time==34 & st38==1))



gen lead2= ((time==32 & st4==1) | (time==23 & st5==1 )| (time==34 & st6==1)  | (time==29 & st15==1) | (time==17 & st19==1) | (time==32 & st21==1) | (time==18 & st24==1) | (time==30 & st26==1) | (time==13 & st31==1) | (time==33 & st33==1) | (time==34 & st34==1) | (time==33 & st40==1) | (time==29 & st43==1) | (time==27 & st45==1) | (time==29 & st47==1) | (time==11 & st48==1) |(time==46 & st50==1)| (time==44 & st7==1)| (time==44 & st22==1)| (time==41 & st11==1)| (time==41 & st23==1)|(time==41 & st28==1)|(time==41 & st51==1)|(time==40 & st46==1)|(time==35 & st14==1)|(time==35 & st30==1)|(time==35 & st38==1))


gen lead1= ((time==33 & st4==1) | (time==24 & st5==1 )| (time==35 & st6==1)  | (time==30 & st15==1) | (time==18 & st19==1) | (time==33 & st21==1) | (time==19 & st24==1) | (time==31 & st26==1) | (time==14 & st31==1) | (time==34 & st33==1) | (time==35 & st34==1) | (time==34 & st40==1) | (time==30 & st43==1) | (time==28 & st45==1) | (time==30 & st47==1) | (time==12 & st48==1) |(time==47 & st50==1)| (time==45 & st7==1)| (time==45 & st22==1)| (time==42 & st11==1)| (time==42 & st23==1)|(time==42 & st28==1)|(time==42 & st51==1)|(time==41 & st46==1)|(time==36 & st14==1)|(time==36 & st30==1)|(time==36 & st38==1))



gen  cont= ((time==34 & st4==1) | (time==25 & st5==1 )| (time==36 & st6==1)  | (time==31 & st15==1) | (time==19 & st19==1) | (time==34 & st21==1) | (time==20 & st24==1) | (time==32 & st26==1) | (time==15 & st31==1) | (time==35 & st33==1) | (time==36 & st34==1) | (time==35 & st40==1) | (time==31 & st43==1) | (time==29 & st45==1) | (time==31 & st47==1) | (time==13 & st48==1) |(time==48 & st50==1)| (time==46 & st7==1)| (time==46 & st22==1)| (time==43 & st11==1)| (time==43 & st23==1)|(time==43 & st28==1)|(time==43 & st51==1)|(time==42 & st46==1)|(time==37 & st14==1)|(time==37 & st30==1)|(time==37 & st38==1))




gen  lag1 = ((time==35 & st4==1) | (time==26 & st5==1 )| (time==37 & st6==1)  | (time==32 & st15==1) | (time==20 & st19==1) | (time==35 & st21==1) | (time==21 & st24==1) | (time==33 & st26==1) | (time==16 & st31==1) | (time==36 & st33==1) | (time==37 & st34==1) | (time==36 & st40==1) | (time==32 & st43==1) | (time==30 & st45==1) | (time==32 & st47==1) | (time==14 & st48==1) |(time==49 & st50==1)| (time==47 & st7==1)| (time==47 & st22==1)| (time==44 & st11==1)| (time==44 & st23==1)|(time==44 & st28==1)|(time==44 & st51==1)|(time==43 & st46==1)|(time==38 & st14==1)|(time==38 & st30==1)|(time==38 & st38==1))

gen  lag2 = ((time==36 & st4==1) | (time==27 & st5==1 )| (time==38 & st6==1)  | (time==33 & st15==1) | (time==21 & st19==1) | (time==36 & st21==1) | (time==22 & st24==1) | (time==34 & st26==1) | (time==17 & st31==1) | (time==37 & st33==1) | (time==38 & st34==1) | (time==37 & st40==1) | (time==33 & st43==1) | (time==31 & st45==1) | (time==33 & st47==1) | (time==15 & st48==1) |(time==50 & st50==1)| (time==48 & st7==1)| (time==48 & st22==1)| (time==45 & st11==1)| (time==45 & st23==1)|(time==45 & st28==1)|(time==45 & st51==1)|(time==44 & st46==1)|(time==39 & st14==1)|(time==39 & st30==1)|(time==39 & st38==1))

gen  lag3 = ((time==37 & st4==1) | (time==28 & st5==1 )| (time==39 & st6==1)  | (time==34 & st15==1) | (time==22 & st19==1) | (time==37 & st21==1) | (time==23 & st24==1) | (time==35 & st26==1) | (time==18 & st31==1) | (time==38 & st33==1) | (time==39 & st34==1) | (time==38 & st40==1) | (time==34 & st43==1) | (time==32 & st45==1) | (time==34 & st47==1) | (time==16 & st48==1) |(time==51 & st50==1)| (time==49 & st7==1)| (time==49 & st22==1)| (time==46 & st11==1)| (time==46 & st23==1)|(time==46 & st28==1)|(time==46 & st51==1)|(time==45 & st46==1)|(time==40 & st14==1)|(time==40 & st30==1)|(time==40 & st38==1))



gen  lag4 = ((time==38 & st4==1) | (time==29 & st5==1 )| (time==40 & st6==1)  | (time==35 & st15==1) | (time==23 & st19==1) | (time==38 & st21==1) | (time==24 & st24==1) | (time==36 & st26==1) | (time==19 & st31==1) | (time==39 & st33==1) | (time==40 & st34==1) | (time==39 & st40==1) | (time==35 & st43==1) | (time==33 & st45==1) | (time==35 & st47==1) | (time==17 & st48==1) |(time==52 & st50==1)| (time==50 & st7==1)| (time==50 & st22==1)| (time==47 & st11==1)| (time==47 & st23==1)|(time==47 & st28==1)|(time==47 & st51==1)|(time==46 & st46==1)|(time==41 & st14==1)|(time==41 & st30==1)|(time==41 & st38==1))


gen  lag5 = ((time==39 & st4==1) | (time==30 & st5==1 )| (time==41 & st6==1)  | (time==36 & st15==1) | (time==24 & st19==1) | (time==39 & st21==1) | (time==25 & st24==1) | (time==37 & st26==1) | (time==20 & st31==1) | (time==40 & st33==1) | (time==41 & st34==1) | (time==40 & st40==1) | (time==36 & st43==1) | (time==34 & st45==1) | (time==36 & st47==1) | (time==18 & st48==1) |(time==53 & st50==1)| (time==51 & st7==1)| (time==51 & st22==1)| (time==48 & st11==1)| (time==48 & st23==1)|(time==48 & st28==1)|(time==48 & st51==1)|(time==47 & st46==1)|(time==42 & st14==1)|(time==42 & st30==1)|(time==42 & st38==1))

gen  lag6 = ((time==40 & st4==1) | (time==31 & st5==1 )| (time==42 & st6==1)  | (time==37 & st15==1) | (time==25 & st19==1) | (time==40 & st21==1) | (time==26 & st24==1) | (time==38 & st26==1) | (time==21 & st31==1) | (time==41 & st33==1) | (time==42 & st34==1) | (time==41 & st40==1) | (time==37 & st43==1) | (time==35 & st45==1) | (time==37 & st47==1) | (time==19 & st48==1) |(time==54 & st50==1)| (time==52 & st7==1)| (time==52 & st22==1)| (time==49 & st11==1)| (time==49 & st23==1)|(time==49 & st28==1)|(time==49 & st51==1)|(time==48 & st46==1)|(time==43 & st14==1)|(time==43 & st30==1)|(time==43 & st38==1))

gen  lag7 = ((time==41 & st4==1) | (time==32 & st5==1 )| (time==43 & st6==1)  | (time==38 & st15==1) | (time==26 & st19==1) | (time==41 & st21==1) | (time==27 & st24==1) | (time==39 & st26==1) | (time==22 & st31==1) | (time==42 & st33==1) | (time==43 & st34==1) | (time==42 & st40==1) | (time==38 & st43==1) | (time==36 & st45==1) | (time==38 & st47==1) | (time==20 & st48==1) |(time==55 & st50==1)| (time==53 & st7==1)| (time==53 & st22==1)| (time==50 & st11==1)| (time==50 & st23==1)|(time==50 & st28==1)|(time==50 & st51==1)|(time==49 & st46==1)|(time==44 & st14==1)|(time==44 & st30==1)|(time==44 & st38==1))


gen  lag8 = ((time==42 & st4==1) | (time==33 & st5==1 )| (time==44 & st6==1)  | (time==39 & st15==1) | (time==27 & st19==1) | (time==42 & st21==1) | (time==28 & st24==1) | (time==40 & st26==1) | (time==23 & st31==1) | (time==43 & st33==1) | (time==44 & st34==1) | (time==43 & st40==1) | (time==39 & st43==1) | (time==37 & st45==1) | (time==39 & st47==1) | (time==21 & st48==1) |(time==56 & st50==1)| (time==54 & st7==1)| (time==54 & st22==1)| (time==51 & st11==1)| (time==51 & st23==1)|(time==51 & st28==1)|(time==51 & st51==1)|(time==50 & st46==1)|(time==45 & st14==1)|(time==45 & st30==1)|(time==45 & st38==1))


gen  lag9 = ((time==43 & st4==1) | (time==34 & st5==1 )| (time==45 & st6==1)  | (time==40 & st15==1) | (time==28 & st19==1) | (time==43 & st21==1) | (time==29 & st24==1) | (time==41 & st26==1) | (time==24 & st31==1) | (time==44 & st33==1) | (time==45 & st34==1) | (time==44 & st40==1) | (time==40 & st43==1) | (time==38 & st45==1) | (time==40 & st47==1) | (time==22 & st48==1) |(time==57 & st50==1)| (time==55 & st7==1)| (time==55 & st22==1)| (time==52 & st11==1)| (time==52 & st23==1)|(time==52 & st28==1)|(time==52 & st51==1)|(time==51 & st46==1)|(time==46 & st14==1)|(time==46 & st30==1)|(time==46 & st38==1))


gen  lag10 = ((time==44 & st4==1) | (time==35 & st5==1 )| (time==46 & st6==1)  | (time==41 & st15==1) | (time==29 & st19==1) | (time==44 & st21==1) | (time==30 & st24==1) | (time==42 & st26==1) | (time==25 & st31==1) | (time==45 & st33==1) | (time==46 & st34==1) | (time==45 & st40==1) | (time==41 & st43==1) | (time==39 & st45==1) | (time==41 & st47==1) | (time==23 & st48==1) |(time==58 & st50==1)| (time==56 & st7==1)| (time==56 & st22==1)| (time==53 & st11==1)| (time==53 & st23==1)|(time==53 & st28==1)|(time==53 & st51==1)|(time==52 & st46==1)|(time==47 & st14==1)|(time==47 & st30==1)|(time==47 & st38==1))








gen  lag3p = ((time>=37 & st4==1) | (time>=28 & st5==1 )| (time>=39 & st6==1)  | (time>=34 & st15==1) | (time>=22 & st19==1) | (time>=37 & st21==1) | (time>=23 & st24==1) | (time>=35 & st26==1) | (time>=18 & st31==1) | (time>=38 & st33==1) | (time>=39 & st34==1) | (time>=38 & st40==1) | (time>=34 & st43==1) | (time>=32 & st45==1) | (time>=34 & st47==1) | (time>=16 & st48==1) |(time>=51 & st50==1)| (time>=49 & st7==1)| (time>=49 & st22==1)| (time>=46 & st11==1)| (time>=46 & st23==1)|(time>=46 & st28==1)|(time>=46 & st51==1)|(time>=45 & st46==1)|(time>=40 & st14==1)|(time>=40 & st30==1)|(time>=40 & st38==1))


gen  lag4p = ((time>=38 & st4==1) | (time>=29 & st5==1 )| (time>=40 & st6==1)  | (time>=35 & st15==1) | (time>=23 & st19==1) | (time>=38 & st21==1) | (time>=24 & st24==1) | (time>=36 & st26==1) | (time>=19 & st31==1) | (time>=39 & st33==1) | (time>=40 & st34==1) | (time>=39 & st40==1) | (time>=35 & st43==1) | (time>=33 & st45==1) | (time>=35 & st47==1) | (time>=17 & st48==1) |(time>=52 & st50==1)| (time>=50 & st7==1)| (time>=50 & st22==1)| (time>=47 & st11==1)| (time>=47 & st23==1)|(time>=47 & st28==1)|(time>=47 & st51==1)|(time>=46 & st46==1)|(time>=41 & st14==1)|(time>=41 & st30==1)|(time>=41 & st38==1))


gen  lag5p = ((time>=39 & st4==1) | (time>=30 & st5==1 )| (time>=41 & st6==1)  | (time>=36 & st15==1) | (time>=24 & st19==1) | (time>=39 & st21==1) | (time>=25 & st24==1) | (time>=37 & st26==1) | (time>=20 & st31==1) | (time>=40 & st33==1) | (time>=41 & st34==1) | (time>=40 & st40==1) | (time>=36 & st43==1) | (time>=34 & st45==1) | (time>=36 & st47==1) | (time>=18 & st48==1) |(time>=53 & st50==1)| (time>=51 & st7==1)| (time>=51 & st22==1)| (time>=48 & st11==1)| (time>=48 & st23==1)|(time>=48 & st28==1)|(time>=48 & st51==1)|(time>=47 & st46==1)|(time>=42 & st14==1)|(time>=42 & st30==1)|(time>=42 & st38==1))

gen  lag8p = ((time>=42 & st4==1) | (time>=33 & st5==1 )| (time>=44 & st6==1)  | (time>=39 & st15==1) | (time>=27 & st19==1) | (time>=42 & st21==1) | (time>=28 & st24==1) | (time>=40 & st26==1) | (time>=23 & st31==1) | (time>=43 & st33==1) | (time>=44 & st34==1) | (time>=43 & st40==1) | (time>=39 & st43==1) | (time>=37 & st45==1) | (time>=39 & st47==1) | (time>=21 & st48==1) |(time>=56 & st50==1)| (time>=54 & st7==1)| (time>=54 & st22==1)| (time>=51 & st11==1)| (time>=51 & st23==1)|(time>=51 & st28==1)|(time>=51 & st51==1)|(time>=50 & st46==1)|(time>=45 & st14==1)|(time>=45 & st30==1)|(time>=45 & st38==1))

gen  lag10p = ((time>=44 & st4==1) | (time>=35 & st5==1 )| (time>=46 & st6==1)  | (time>=41 & st15==1) | (time>=29 & st19==1) | (time>=44 & st21==1) | (time>=30 & st24==1) | (time>=42 & st26==1) | (time>=25 & st31==1) | (time>=45 & st33==1) | (time>=46 & st34==1) | (time>=45 & st40==1) | (time>=41 & st43==1) | (time>=39 & st45==1) | (time>=41 & st47==1) | (time>=23 & st48==1) |(time>=58 & st50==1)| (time>=56 & st7==1)| (time>=56 & st22==1)| (time>=53 & st11==1)| (time>=53 & st23==1)|(time>=53 & st28==1)|(time>=53 & st51==1)|(time>=52 & st46==1)|(time>=47 & st14==1)|(time>=47 & st30==1)|(time>=47 & st38==1))

gen  lag11p = ((time>=45 & st4==1) | (time>=36 & st5==1 )| (time>=47 & st6==1)  | (time>=42 & st15==1) | (time>=30 & st19==1) | (time>=45 & st21==1) | (time>=31 & st24==1) | (time>=43 & st26==1) | (time>=26 & st31==1) | (time>=46 & st33==1) | (time>=47 & st34==1) | (time>=46 & st40==1) | (time>=42 & st43==1) | (time>=40 & st45==1) | (time>=42 & st47==1) | (time>=24 & st48==1) |(time>=59 & st50==1)| (time>=57 & st7==1)| (time>=57 & st22==1)| (time>=54 & st11==1)| (time>=54 & st23==1)|(time>=54 & st28==1)|(time>=54 & st51==1)|(time>=53 & st46==1)|(time>=48 & st14==1)|(time>=48 & st30==1)|(time>=48 & st38==1))









gen treated=cond(st4==1|st5==1 | st6==1 | st15==1| st19==1 | st21==1 | st24==1 | st26==1 | st31==1 | st33==1 | st34==1 | st40==1 | st43==1 | st45==1 | st47==1 | st48==1 |st50==1| st7==1| st22==1| st11==1| st23==1|st28==1|st51==1|st46==1|st14==1|st30==1| st38==1,1,0)
gen treatedt=treated*time






save estdata, replace
