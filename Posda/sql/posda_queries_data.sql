--
-- PostgreSQL database dump
--

-- Dumped from database version 8.4.20
-- Dumped by pg_dump version 9.5.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;
SET row_security = off;

SET search_path = db_version, pg_catalog;

--
-- Data for Name: version; Type: TABLE DATA; Schema: db_version; Owner: quasar
--

COPY version (version) FROM stdin;
3
\.


SET search_path = public, pg_catalog;

--
-- Data for Name: background_subprocess; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY background_subprocess (background_subprocess_id, subprocess_invocation_id, input_rows_processed, command_executed, foreground_pid, background_pid, when_script_started, when_background_entered, when_script_ended, user_to_notify, process_error) FROM stdin;
\.


--
-- Name: background_subprocess_background_subprocess_id_seq; Type: SEQUENCE SET; Schema: public; Owner: posda
--

SELECT pg_catalog.setval('background_subprocess_background_subprocess_id_seq', 1, false);


--
-- Data for Name: background_subprocess_params; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY background_subprocess_params (background_subprocess_id, param_index, param_value) FROM stdin;
\.


--
-- Data for Name: chained_query; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY chained_query (chained_query_id, from_query, to_query, caption) FROM stdin;
1	PixelTypes	FileIdByPixelType	files
\.


--
-- Name: chained_query_chained_query_id_seq; Type: SEQUENCE SET; Schema: public; Owner: posda
--

SELECT pg_catalog.setval('chained_query_chained_query_id_seq', 1, true);


--
-- Data for Name: chained_query_cols_to_params; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY chained_query_cols_to_params (chained_query_id, from_column_name, to_parameter_name) FROM stdin;
1	samples_per_pixel	samples_per_pixel
1	bits_allocated	bits_allocated
1	bits_stored	bits_stored
1	high_bit	high_bit
1	pixel_representation	pixel_representation
1	planar_configuration	planar_configuration
1	photometric_interpretation	photometric_interpretation
\.


--
-- Data for Name: dbif_query_args; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY dbif_query_args (query_invoked_by_dbif_id, arg_index, arg_name, arg_value) FROM stdin;
3	0	from	2016-10-01
3	1	to	2017-05-26
3	2	collection	HNSCC
8	0	id	3
9	0	user	tracyn
11	0	user	bbennett
13	0	user	bbennett
14	0	query_name	ListOfQueriesPerformed
15	0	query_name	RoundInfoLastCompleteRound
16	0	id	2
18	0	id	16
19	0	collection	CPTAC-UCEC
19	1	from	2017-04-01
19	2	to	2017-05-30
20	0	from	2016-10-01
20	1	to	2017-05-26
21	0	from	2016-10-01
21	1	to	2017-05-26
22	0	id	3
23	0	user	bbennett
23	1	from	2016-10-01
23	2	to	2017-05-26
24	0	collection	CPTAC-LUAD
24	1	from	2017-04-01
24	2	to	2017-05-30
25	0	collection	CPTAC-GBM
25	1	from	2017-04-01
25	2	to	2017-05-30
26	0	collection	CC-Radiomics
27	0	collection	CC-Radiomics
28	0	collection	CC-Radiomics
29	0	project_name	CC-Radiomics
29	1	site_name	MDA
30	0	collection	CC-Radiomics
31	0	collection	CCRadiomics
32	0	collection	CC-Radiomics-Phantom
33	0	collection	CC-Radiomics-Phantom
34	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.220708113216785414398691493203
35	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.220708113216785414398691493203
36	0	collection	CC-Radiomics-Phantom
37	0	collection	CC-Radiomics-Phantom
38	0	collection	CC-Radiomics-Phantom
39	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.220708113216785414398691493203
40	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.223023553933315323279577191346
41	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.223023553933315323279577191346
42	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.475461168416060202967131388872
43	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.204661361703815650322205867468
44	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.322295465871416785161427957771
45	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.190106834028845478953492982396
46	0	collection	CC-Radiomics-Phantom
47	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.292965251033655040499417097652
54	0	tag	Universal
55	0	tag	universal
56	0	name_like	List%
57	0	tag	univ%
58	0	tag	
59	0	tag	
60	0	tag	struct%
61	0	name	GetDupsFromSimilarDupContourCounts
62	0	name	GetDupsFromSimilarDupContourCounts
63	0	name	GetDupsFromSimilarDupContourCounts
64	0	name	GetDupsFromSimilarDupContourCounts
65	0	tag	
66	0	tag	%niver%
67	0	name	ShowPopUps
68	0	name_like	Add%
69	0	name	AddTagToQuery
71	0	name	AddTagToQuery
72	0	name	AddTagToQuery
73	0	name	AddTagToQuery
74	0	name	AddTagToQuery
75	0	name	AddTagToQuery
76	0	name	AddTagToQuery
77	0	tag	fubar
77	1	name	AddTagToQuery
78	0	name	AddTagToQuery
79	0	name	AddTagToQuery
80	0	name	AddTagToQuery
82	0	name_like	Add%
83	0	tag	query_tags
83	1	name	AddTagToQuery
84	0	name	AddTagToQuery
85	0	name	AddTagToQuery
86	0	name	AddTagToQuery
87	0	tag	fubar
87	1	name	AddTagToQuery
88	0	name	AddTagToQuery
89	0	name	AddTagToQuery
90	0	name	AddTagToQuery
91	0	name	AddTagToQuery
92	0	schema	posda
93	0	schema	posda_queries
94	0	schema	posda_queries
96	0	schema	posda_phi_simple
98	0	schema	posda_files
99	0	name_like	Add%
102	0	schema	posda_files
103	0	tag	Not%
104	0	tag	Not%
105	0	tag	Not%
106	0	tag	Back%
107	0	db_name	N_posda_files
108	0	collection	CC-Radiomics-Phantom
109	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.220708113216785414398691493203
110	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.220708113216785414398691493203
111	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.220708113216785414398691493203
112	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.220708113216785414398691493203
113	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.223023553933315323279577191346
114	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.117186275848609914535670155378
115	0	collection	CC-Radiomics-Phantom
116	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.117186275848609914535670155378
117	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.536281742355588428432922661245
118	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.536281742355588428432922661245
119	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.176144942577207031829258178045
120	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.193561172490403687930792766252
121	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.143646191257500210501579258168
122	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.698687192324203940430464046024
123	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.424135008623254977083314152454
124	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.290449674181173273327334367881
125	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.642788168978017826353388644787
126	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.128262673454337666337075997757
127	0	collection	CC-Radiomics-Phantom
127	1	from	2017-04-01
127	2	to	2017-05-30
128	0	user	tracyn
129	0	id	19
130	0	user	tracyn
131	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.254832383954599088232540412537
134	0	collection	CC-Radiomics-Phantom
135	0	collection	CC-Radiomics-Phantom
136	0	collection	CC-Radiomics-Phantom
136	1	from	2016-10-01
136	2	to	2017-05-26
137	0	collection	CC-Radiomics-Phantom
137	1	site	MDA
138	0	collection	CC-Radiomics-Phantom
138	1	site	MDA
139	0	collection	CC-Radiomics-Phantom
139	1	site	MDA
139	2	from	2016-10-01
139	3	to	2017-05-26
140	0	collection	CC-Radiomics-Phantom
141	0	project_name	CC-Radiomics-Phantom
141	1	site_name	MDA
142	0	project_name	CC-Radiomics-Phantom
142	1	site_name	MDA
143	0	project_name	CC-Radiomics-Phantom
143	1	site_name	MDA
143	2	status	Blank
144	0	project_name	CC-Radiomics-Phantom
144	1	site_name	MDA
144	2	status	Good
145	0	project_name	CC-Radiomics-Phantom
145	1	site_name	MDA
145	2	status	
146	0	project_name	CC-Radiomics-Phantom
146	1	site_name	MDA
147	0	project_name	CC-Radiomics-Phantom
147	1	site_name	MDA
148	0	collection	CC-Radiomics-Phantom
149	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.137125892409456229662234563386
150	0	collection	CCR-Radiomics-Phantom
151	0	collection	CCR-Radiomics-Phantom
152	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.137125892409456229662234563386
155	0	tag	Hierarchy
156	0	name	PatientStudySeriesHierarchyByCollectionMatchingSeriesDesc
158	0	name	PatientStudySeriesHierarchyByCollectionMatchingSeriesDesc
159	0	collection	CCR-Radiomics-Phantom
160	0	collection	CCR-Radiomics-Phantom
161	0	collection	CC-Radiomics-Phantom
162	0	project_name	CC-Radiomics
162	1	site_name	MDA
163	0	project_name	CC-Radiomics-Phantom
163	1	site_name	MDA
165	0	scan_id	17
166	0	scan_id	17
167	0	project_name	HNSCC
167	1	site_name	MDA
170	0	name_like	%Series%
171	0	schema	posda_files
172	0	schema	posda_phi
173	0	schema	posda_phi_simple
175	0	schema	dicom_dd
176	0	name	PatientStudySeriesHierarchyByCollectionMatchingSeriesDesc
179	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.1706.8040.309230955084954012661946243312
180	0	collection	PhantomFDA
181	0	collection	Phantom-FDA
182	0	collection	Phantom_FDA
183	0	start_time	2017-03-01
183	1	end_time	2017-05-31
184	0	collection	Phantom FDA
185	0	collection	Phantom FDA
186	0	collection	Phantom FDA
186	1	site	MDA
186	2	from	2016-10-01
186	3	to	2017-05-30
187	0	collection	Phantom FDA
187	1	site	FDA
187	2	from	2016-10-01
187	3	to	2017-05-30
188	0	series_instance_uid	1.2.840.113704.1.111.3880.1231436387.6
189	0	series_instance_uid	1.2.840.113704.1.111.3880.1231436387.6
190	0	sop_instance_uid	1.3.6.1.4.1.9590.100.1.1.961605825618015672.360386190141343
191	0	project_name	HNSCC
191	1	site_name	MDA
191	2	status	Bad
192	0	collection	LCTSC
192	1	from	2016-10-01
192	2	to	2017-05-31
193	0	project_name	HNSCC
193	1	site_name	MDA
193	2	status	Good
194	0	project_name	HNSCC
194	1	site_name	MDA
194	2	status	Blank
197	0	collection	Phantom-FDA
197	1	site	FDA
197	2	from	2016-10-01
197	3	to	2017-05-31
199	0	collection	Phantom FDA
199	1	site	FDA
199	2	from	2016-10-01
199	3	to	2017-05-31
200	0	from	2017-05-30
200	1	to	2017-05-31
201	0	from	2017-05-30
201	1	to	2017-05-31
202	0	id	187
203	0	collection	Phantom FDA
203	1	site	FDA
203	2	from	2015-01-01
203	3	to	2017-05-31
204	0	sop_instance_uid	1.3.6.1.4.1.9590.100.1.1.961605917014013047.362654891241447
205	0	collection	Phantom FDA
205	1	site	FDA
206	0	collection	Phantom FDA
206	1	from	2017-01-01
206	2	to	2017-05-31
207	0	start_time	2017-03-01
207	1	end_time	2017-05-31
208	0	start_time	2017-03-01
208	1	end_time	2017-05-31
208	2	project_name	LCTSC
209	0	collection	LCTSC
209	1	from	2016-10-01
209	2	to	2017-05-31
211	0	collection	LTCSC
211	1	from	2017-05-24
211	2	to	2017-06-01
212	0	collection	LCTSC
212	1	from	2017-05-24
212	2	to	2017-06-01
213	0	from	2017-05-24
213	1	to	2017-06-01
213	2	collection	LCTSC
214	0	from	2017-05-24
214	1	to	2017-06-01
215	0	collection	LCTSC
215	1	from	2017-05-24
215	2	to	2017-06-01
216	0	from	2017-05-31
216	1	to	2017-06-01
217	0	CollectionLike	LCT%
218	0	from	2017-05-31
218	1	to	2017-06-01
219	0	collection	LCTSC
220	0	from	2017-05-31
220	1	to	2017-06-01
222	0	from	2017-05-31
222	1	to	2017-06-01
223	0	query_name	RoundInfoLastCompleteRound
224	0	n	10
225	0	n	10
226	0	id	183
227	0	start_time	2017-05-01
227	1	end_time	2017-05-20
228	0	start_time	2017-03-01
228	1	end_time	2017-05-31
229	0	start_time	2017-05-30
229	1	end_time	2017-06-01
230	0	start_time	2017-05-30
230	1	end_time	2017-06-01
231	0	start_time	2017-05-01
231	1	end_time	2017-06-01
232	0	start_time	2017-05-01
232	1	end_time	2017-06-01
233	0	start_time	2017-04-01
233	1	end_time	2017-05-01
234	0	start_time	2017-03-01
234	1	end_time	2017-04-01
235	0	start_time	2017-02-01
235	1	end_time	2017-03-01
236	0	start_time	2017-01-01
236	1	end_time	2017-02-01
237	0	start_time	2016-12-01
237	1	end_time	2017-01-01
238	0	user	bbennett
238	1	from	2017-05-31
238	2	to	2017-06-01
239	0	n	10
240	0	n	20
241	0	start_time	2016-11-01
241	1	end_time	2017-12-01
242	0	n	20
243	0	id	241
244	0	start_time	2016-10-01
244	1	end_time	2017-11-01
245	0	n	20
246	0	id	241
247	0	id	244
248	0	id	241
249	0	start_time	2016-10-01
249	1	end_time	2016-11-01
250	0	start_time	2016-11-01
250	1	end_time	2016-12-01
251	0	n	20
252	0	start_time	2016-09-01
252	1	end_time	2016-10-01
253	0	start_time	2016-08-01
253	1	end_time	2016-09-01
254	0	start_time	2016-07-01
254	1	end_time	2016-08-01
255	0	start_time	2016-06-01
255	1	end_time	2016-07-01
256	0	start_time	2016-05-01
256	1	end_time	2016-06-01
257	0	start_time	2016-04-01
257	1	end_time	2016-05-01
258	0	start_time	2016-03-01
258	1	end_time	2016-04-01
259	0	start_time	2016-02-01
259	1	end_time	2016-03-01
260	0	name	TotalsByDateRange
261	0	start_time	2016-01-01
261	1	end_time	2016-02-01
262	0	start_time	2015-12-01
262	1	end_time	2016-01-01
263	0	start_time	2015-11-01
263	1	end_time	2015-12-01
264	0	start_time	2015-10-01
264	1	end_time	2015-11-01
265	0	start_time	2015-09-01
265	1	end_time	2015-10-01
266	0	start_time	2015-01-01
266	1	end_time	2015-10-01
267	0	user	bbennett
267	1	from	2017-05-31
267	2	to	2017-06-01
268	0	id	227
269	0	id	228
270	0	id	229
271	0	id	230
272	0	start_time	2017-03-01
272	1	end_time	2017-04-01
273	0	user	bbennett
273	1	from	2017-05-31
273	2	to	2017-06-01
274	0	user	bbennett
274	1	from	2017-05-31
274	2	to	2017-06-01
275	0	id	272
276	0	start_time	2017-04-01
276	1	end_time	2017-05-01
277	0	user	bbennett
277	1	from	2017-05-31
277	2	to	2017-06-01
278	0	user	bbennett
278	1	from	2017-05-31
278	2	to	2017-06-01
279	0	n	30
280	0	start_time	2017-05-30
280	1	end_time	2017-05-31
281	0	start_time	2017-05-31
281	1	end_time	2017-06-01
282	0	from	2017-05-30
282	1	to	2017-05-31
283	0	from	2017-05-24
283	1	to	2017-05-31
285	0	user	tracyn
285	1	from	2017-05-31
285	2	to	2017-06-01
286	0	user	tracyn
286	1	from	2017-05-30
286	2	to	2017-06-01
287	0	id	209
288	0	from	2017-05-24
288	1	to	2017-05-31
289	0	from	2017-05-24
289	1	to	2017-05-31
289	2	collection	LCTSC
290	0	collection	LCTSC
290	1	site	MGH
291	0	collection	LCTSC
291	1	site	MGH
291	2	from	2017-05-24
291	3	to	2017-05-31
292	0	collection	LCTSC
294	0	collection	LCTSC
295	0	collection	LCTSC
298	0	collection	LCTSC
299	0	collection	LCTSC
300	0	collection	LCTSC
301	0	collection	LCTSC
302	0	collection	HNSCC
303	0	collection	HNSCC
304	0	collection	HNSCC
305	0	num_dup_contours	2571
306	0	num_dup_contours	2571
307	0	file_id	449138
308	0	file_id	333049
309	0	collection	HNSCC
310	0	num_dup_contours	1365
311	0	file_id	448909
312	0	file_id	448908
313	0	file_id	448906
314	0	file_id	349560
315	0	n	50
316	0	user	tracyn
316	1	from	2017-05-30
316	2	to	2017-05-31
317	0	id	207
318	0	collection	HNSCC
318	1	site	MDA
319	0	collection	HNSCC
319	1	site	MDA
320	0	collection	HNSCC
320	1	site	MDA
321	0	collection	HNSCC
321	1	site	MDA
322	0	collection	HNSCC
322	1	site	MDA
323	0	collection	HNSCC
323	1	site	MDA
324	0	n	50
325	0	id	244
327	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.7009.2401.301854378897730812498385210968
328	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.7009.2401.301854378897730812498385210968
329	0	CollectionLike	CC%
330	0	CollectionLike	CC%
331	0	collection	CC-Radiomics-Phantom
331	1	site	MDA
332	0	collection	CCR-Radiomics-Phantom
332	1	site	MDA
333	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.7009.2401.301854378897730812498385210968
334	0	CollectionLike	QIN%
335	0	collection	QIN-Lung
335	1	from	2017-05-30
335	2	to	2017-05-31
336	0	from	2015-05-30
336	1	to	2017-05-31
336	2	collection	QIN-Lung
337	0	from	2015-05-30
337	1	to	2017-05-31
337	2	collection	QIN-LUNG
338	0	CollectionLike	QIN%
339	0	from	2015-05-30
339	1	to	2017-05-31
339	2	collection	QIN LUNG CT
340	0	from	2015-05-30
340	1	to	2017-05-31
340	2	collection	QIN Lung CT
341	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.7009.2401.301854378897730812498385210968
342	0	n	50
344	0	from	2017-06-01
344	1	to	2017-06-02
346	0	user	bbennett
346	1	from	2017-06-01
346	2	to	2017-06-02
351	0	collection	LCTSC
351	1	from	2016-10-01
351	2	to	2017-06-02
352	0	collection	LCTSC
352	1	from	2016-10-01
352	2	to	2017-06-02
353	0	collection	LCTSC
353	1	from	2016-10-01
353	2	to	2017-06-02
355	0	collection	QIN LUNG CT
355	1	from	2017-05-23
355	2	to	2017-06-02
358	0	collection	QIN LUNG CT
358	1	from	2017-05-23
358	2	to	2017-06-02
359	0	collection	QIN Lung CT
359	1	from	2017-05-23
359	2	to	2017-06-02
360	0	from	2017-06-02
360	1	to	2017-06-03
361	0	from	2017-06-02
361	1	to	2017-06-03
364	0	round_id	178157
365	0	from	2017-06-02
365	1	to	2017-06-03
367	0	from	2017-06-02
367	1	to	2017-06-03
368	0	from	2017-06-01
368	1	to	2017-06-02
369	0	round_id	178157
370	0	collection	Phantom FDA
370	1	site	FDA
371	0	collection	Phantom FDA
371	1	site	FDA
372	0	collection	LGG-1p19qDeletion
372	1	from	2016-10-01
372	2	to	2017-06-02
373	0	collection	LGG-1p19qDeletion
373	1	from	2016-10-01
373	2	to	2017-06-02
374	0	collection	LGG-1p19qDeletion
375	0	collection	LGG-1p19qDeletion
376	0	collection	LGG-1p19qDeletion
377	0	project_name	LGG-1p19qDeletion
377	1	site_name	Mayo
378	0	from	2017-06-02
378	1	to	2017-06-03
379	0	from	2017-06-02
379	1	to	2017-06-03
380	0	collection	ACRIN-6684
380	1	from	2017-06-02
380	2	to	2017-06-03
381	0	collection	ACRIN-6684
381	1	from	2017-06-02
381	2	to	2017-06-03
382	0	collection	ACRIN-6684
384	0	scan_id	19
385	0	site	CC%
386	0	CollectionLike	CC%
389	0	collection	CC-Radiomics-Phantom
389	1	from	2017-05-02
389	2	to	2017-06-03
391	0	collection	CC-Radiomics-Phantom
391	1	from	2016-01-01
391	2	to	2017-06-03
392	0	scan_id	18
399	0	scan_id	20
401	0	scan_id	20
402	0	scan_id	20
404	0	collection	Phantom FDA
404	1	site	FDA
405	0	from	2017-05-26
405	1	to	2017-06-03
406	0	from	2017-06-02
406	1	to	2017-06-03
407	0	collection	LGG-1p19qDeletion
407	1	site	Mayo
408	0	collection	QIN Lung CT
408	1	from	2017-05-23
408	2	to	2017-06-03
409	0	collection	QIN LUNG CT
409	1	from	2017-05-23
409	2	to	2017-06-03
418	0	round_id	178157
419	0	project_name	Phantom FDA
419	1	site_name	FDA
420	0	from	2016-10-01
420	1	to	2017-06-02
421	0	from	2017-05-01
421	1	to	2017-06-03
422	0	collection	Head-Neck-PET-CT
422	1	from	2017-05-01
422	2	to	2017-06-03
423	0	from	2017-05-01
423	1	to	2017-06-01
430	0	collection	Head-Neck-PET-CT
431	0	collection	Head-Neck-PET-CT
432	0	collection	Head-Neck-PET-CT
432	1	from	2017-05-29
432	2	to	2017-06-06
433	0	from	2017-05-29
433	1	to	2017-06-06
434	0	round_id	174965
435	0	from	2017-05-29
435	1	to	2017-06-06
436	0	from	2017-05-29
436	1	to	2017-06-06
437	0	id	419
438	0	name	TotalsByDateRange
439	0	name_like	Add%
440	0	tag	Back%
441	0	tag	Not%
442	0	tag	Not%
444	0	name	PatientStudySeriesHierarchyByCollectionSiteExt
445	0	collection	CC-Radiomics-Phantom
445	1	site	CC%
446	0	collection	CC-Radiomics-Phantom
446	1	site	FDA
447	0	CollectionLike	CC%
448	0	collection	CC-Radiomics-Phantom
448	1	site	MDA
450	0	scan_id	20
451	0	n	50
452	0	collection	CC-Radiomics-Phantom
455	0	scan_id	21
456	0	scan_id	21
457	0	collection	Head-Neck-PET-CT
457	1	site	McGill
457	2	from	2017-05-01
457	3	to	2017-06-05
458	0	collection	CC-Radiomics-Phantom
459	0	collection	CC-Radiomics-Phantom
460	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.4020.5263.220708113216785414398691493203
461	0	num_dup_contours	2571
462	0	collection	Head-Neck-PET-CT
462	1	site	McGill
462	2	from	2017-05-01
462	3	to	2017-06-06
463	0	collection	CC-Radiomics-Phantom
463	1	site	MDA
463	2	from	2017-05-29
463	3	to	2017-06-06
464	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.7009.2401.301854378897730812498385210968
466	0	collection	Head-Neck-PET-CT
466	1	site	McGill
466	2	from	2017-05-06
466	3	to	2017-06-07
467	0	collection	Head-Neck-PET-CT
467	1	site	McGill
467	2	from	2017-05-06
467	3	to	2017-06-07
468	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.5168.2407.123543939845214571517859948396
469	0	collection	LCTSC
469	1	from	2017-05-01
469	2	to	2017-06-07
470	0	collection	Head-Neck-PET-CT
471	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.5168.2407.280349120336666115856032612012
472	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.5168.2407.280349120336666115856032612012
473	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.5168.2407.280349120336666115856032612012
475	0	collection	LCTSC
475	1	from	2017-06-01
475	2	to	2017-06-07
476	0	collection	LCTSC
476	1	site	McGill
476	2	from	2017-05-01
476	3	to	2017-06-07
477	0	collection	Head-Neck-PET-CT
477	1	site	McGill
477	2	from	2017-05-06
477	3	to	2017-06-07
478	0	collection	LCTSC
478	1	site	MGH
478	2	from	2017-05-01
478	3	to	2017-06-07
479	0	collection	LCTSC
479	1	from	2017-05-01
479	2	to	2017-06-07
480	0	collection	LCTSC
480	1	from	2017-05-01
480	2	to	2017-06-01
481	0	collection	LCTSC
481	1	from	2017-04-01
481	2	to	2017-06-07
482	0	collection	Head-Neck-CT-Pet
482	1	from	2017-05-06
482	2	to	2017-06-07
484	0	collection	Head-Neck-PET-CT
484	1	from	2017-05-06
484	2	to	2017-06-07
485	0	site	Mayo
486	0	from	2017-05-06
486	1	to	2017-06-07
486	2	collection	LGG-1p19qDeletion
487	0	from	2017-01-06
487	1	to	2017-06-07
487	2	collection	LGG-1p19qDeletion
488	0	collection	LGG-1p19qDeletion
490	0	num_dup_contours	4690
491	0	CollectionLike	QIN%
492	0	collection	QIN-BRAIN-DSC-MRI
492	1	site	MCWISC
493	0	collection	QIN-BRAIN-DSC-MRI
493	1	site	MCWISC
493	2	from	2016-01-01
493	3	to	2017-06-07
494	0	collection	QIN-BRAIN-DSC-MRI
495	0	collection	QIN-BRAIN-DSC-MRI
496	0	collection	QIN-BRAIN-DSC-MRI
497	0	collection	QIN-BRAIN-DSC-MRI
498	0	collection	QIN-BRAIN-DSC-MRI
499	0	collection	QIN-BRAIN-DSC-MRI
500	0	collection	QIN-BRAIN-DSC-MRI
501	0	collection	QIN-BRAIN-DSC-MRI
507	0	element_sig_pattern	(0018,1030)
507	1	vr	UI
508	0	user	bbennett
508	1	from	2017-06-07
508	2	to	2017-06-08
509	0	id	507
510	0	operation_name	SimplePhiScan
511	0	operation_name	SimplePhiScan
512	0	collection	QIN-BRAIN-DSC-MRI
513	0	collection	QIN-BRAIN-DSC-MRI
514	0	collection	QIN-BRAIN-DSC-MRI
515	0	collection	QIN-BRAIN-DSC-MRI
516	0	collection	QIN-BRAIN-DSC-MRI
517	0	collection	QIN-BRAIN-DSC-MRI
518	0	collection	QIN-BRAIN-DSC-MRI
519	0	collection	QIN-BRAIN-DSC-MRI
520	0	collection	QIN-BRAIN-DSC-MRI
521	0	operation_name	SimplePhiScan
522	0	operation_name	SimplePhiScan
523	0	operation_name	SimplePhiScan
525	0	user	bbennett
525	1	from	2017-06-07
525	2	to	2017-06-08
526	0	user	bbennett
526	1	from	2017-06-07 13:00
526	2	to	2017-06-08
527	0	photometric_interpretation	MONOCHROME2
527	1	samples_per_pixel	1
527	2	bits_allocated	16
527	3	bits_stored	16
527	4	high_bit	15
527	5	pixel_representation	1
527	6	planar_configuration	<undef>
528	0	photometric_interpretation	MONOCHROME2
528	1	samples_per_pixel	1
528	2	bits_allocated	8
528	3	bits_stored	8
528	4	high_bit	7
528	5	pixel_representation	0
528	6	planar_configuration	0
529	0	photometric_interpretation	RGB
529	1	samples_per_pixel	3
529	2	bits_allocated	8
529	3	bits_stored	8
529	4	high_bit	7
529	5	pixel_representation	
529	6	planar_configuration	
530	0	photometric_interpretation	MONOCHROME2
530	1	samples_per_pixel	1
530	2	bits_allocated	16
530	3	bits_stored	16
530	4	high_bit	15
530	5	pixel_representation	1
530	6	planar_configuration	
531	0	photometric_interpretation	MONOCHROME2
531	1	samples_per_pixel	1
531	2	bits_allocated	16
531	3	bits_stored	16
531	4	high_bit	15
531	5	pixel_representation	1
531	6	planar_configuration	0
532	0	photometric_interpretation	MONOCHROME2
532	1	samples_per_pixel	1
532	2	bits_allocated	16
532	3	bits_stored	16
532	4	high_bit	15
532	5	pixel_representation	1
532	6	planar_configuration	
533	0	photometric_interpretation	MONOCHROME2
533	1	samples_per_pixel	1
533	2	bits_allocated	16
533	3	bits_stored	16
533	4	high_bit	15
533	5	pixel_representation	1
533	6	planar_configuration	
534	0	photometric_interpretation	RGB
534	1	samples_per_pixel	3
534	2	bits_allocated	8
534	3	bits_stored	8
534	4	high_bit	7
534	5	pixel_representation	
534	6	planar_configuration	
535	0	photometric_interpretation	RGB
535	1	samples_per_pixel	3
535	2	bits_allocated	8
535	3	bits_stored	8
535	4	high_bit	7
535	5	pixel_representation	0
535	6	planar_configuration	0
536	0	photometric_interpretation	RGB
536	1	samples_per_pixel	3
536	2	bits_allocated	8
536	3	bits_stored	8
536	4	high_bit	7
536	5	pixel_representation	0
536	6	planar_configuration	0
537	0	photometric_interpretation	RGB
537	1	samples_per_pixel	3
537	2	bits_allocated	8
537	3	bits_stored	8
537	4	high_bit	7
537	5	pixel_representation	<undef>
537	6	planar_configuration	<undef>
538	0	photometric_interpretation	RGB
538	1	samples_per_pixel	3
538	2	bits_allocated	8
538	3	bits_stored	8
538	4	high_bit	7
538	5	pixel_representation	0
538	6	planar_configuration	0
540	0	photometric_interpretation	RGB
540	1	samples_per_pixel	3
540	2	bits_allocated	8
540	3	bits_stored	8
540	4	high_bit	7
540	5	pixel_representation	0
540	6	planar_configuration	0
541	0	photometric_interpretation	RGB
541	1	samples_per_pixel	3
541	2	bits_allocated	8
541	3	bits_stored	8
541	4	high_bit	7
541	5	pixel_representation	
541	6	planar_configuration	
542	0	photometric_interpretation	RGB
542	1	samples_per_pixel	3
542	2	bits_allocated	8
542	3	bits_stored	8
542	4	high_bit	7
542	5	pixel_representation	
542	6	planar_configuration	
543	0	photometric_interpretation	RGB
543	1	samples_per_pixel	3
543	2	bits_allocated	8
543	3	bits_stored	8
543	4	high_bit	7
543	5	pixel_representation	0
543	6	planar_configuration	0
545	0	collection	ACRIN-FLT-Breast
548	0	n	50
549	0	n	50
549	1	from	2017-06-08
549	2	to	2017-06-09
550	0	from	2017-06-08
550	1	to	2017-06-09
550	2	n	50
552	0	tag	dicom_file_type
554	0	collection	Head-Neck-PET-CT
555	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.5168.2407.294816629061094178979643159266
556	0	from	2017-06-08
556	1	to	2017-06-09
556	2	n	50
559	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.5168.2407.294816629061094178979643159266
560	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.5168.2407.294816629061094178979643159266
561	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.5168.2407.319657356866120093113759269116
562	0	collection	Head-Neck-PET-CT
562	1	site	McGill
563	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.5168.2407.251119053321053528236599671471
564	0	sop_instance_uid	1.3.6.1.4.1.14519.5.2.1.5168.2407.186510701700181936668145607990
565	0	collection	Head-Neck-PET-CT
565	1	site	McGill
565	2	patient_id	HGJ-HN_001
566	0	collection	Head-Neck-PET-CT
566	1	site	McGill
566	2	patient_id	HGJ-HN_001
567	0	collection	Head-Neck-PET-CT
567	1	site	McGill
567	2	patient_id	HGJ-HN_001
568	0	collection	Head-Neck-PET-CT
568	1	site	McGill
568	2	patient_id	HN-HGJ-001
569	0	collection	Head-Neck-PET-CT
569	1	site	McGill
569	2	patient_id	HN-HGJ-001
569	3	visibility	hidden
570	0	collection	Head-Neck-PET-CT
570	1	site	McGill
570	2	patient_id	HGJ-HN_001
570	3	visibility	hidden
571	0	collection	Head-Neck-PET-CT
571	1	site	McGill
571	2	patient_id	HGJ-HN_001
572	0	collection	Head-Neck-PET-CT
572	1	site	McGill
572	2	patient_id	HGJ-HN_001
573	0	collection	Head-Neck-PET-CT
573	1	site	McGill
573	2	patient_id	HGJ-HN_001
574	0	from	2017-05-01
574	1	to	2017-06-01
575	0	from	2010-05-01
575	1	to	2017-06-01
576	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.1706.8040.313722487844684025271524351552
577	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.1706.8040.313722487844684025271524351552
578	0	project_name	HNSCC
578	1	site_name	MDA
578	2	patient_id	HNSCC-01-0138
579	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.1706.8040.313722487844684025271524351552
580	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.1706.8040.401611994206154872571485733569
581	0	from	2017-06
581	1	to	2017-06-10
582	0	from	2017-06-01
582	1	to	2017-06-10
593	0	name	PatientStudySeriesHierarchyByCollectionSiteExt
596	0	collection	LGG-1p19qdeletion
597	0	collection	LGG-1p19qDeletion
598	0	collection	HNSCC
598	1	site	MDA
599	0	collection	HNSCC
600	0	collection	HNSCC
600	1	site	MDA
601	0	collection	HNSCC
602	0	collection	HNSCC
603	0	collection	HNSCC
604	0	collection	HNSCC
606	0	collection	LGG-1p19qDeletion
611	0	collection	QIN LUNG CT
612	0	collection	TCGA-BLCA
612	1	site	MDA
612	2	from	2013-01-01
612	3	to	2017-06-11
613	0	collection	QIN LUNG CT
613	1	site	Moffitt
613	2	from	2010-06-01
613	3	to	2017-06-10
614	0	collection	TCGA-UCEC
614	1	site	MDA
614	2	from	2013-01-01
614	3	to	2017-06-11
615	0	collection	TCGA-PRAD
615	1	site	MDA
615	2	from	2013-01-01
615	3	to	2017-06-11
616	0	from	2013-06-09
616	1	to	2017-06-11
618	0	collection	HNSCC
618	1	from	2017-06-08
618	2	to	2017-06-09
620	0	from	2017-06-12
620	1	to	2017-06-13
621	0	collection	LGG-1p19qDeletion
621	1	site	Mayo
621	2	from	2017-05-12
621	3	to	2017-06-13
622	0	series_instance_uid	1.3.6.1.4.1.14519.5.2.1.3344.2526.668680937548204209679243877825
623	0	collection	Exceptional-Responders
623	1	site	NCI
624	0	collection	Exceptional-Responders
624	1	site	NCI
625	0	from	2013-06-11
625	1	to	2017-06-13
626	0	collection	Exceptional-Responders
626	1	site	NCI
626	2	from	2015-06-11
626	3	to	2017-06-13
628	0	collection	Head-Neck-PET-CT
628	1	site	McGill
628	2	from	2017-02-01
628	3	to	2017-06-14
629	0	collection	LCTSC
629	1	site	MGH
629	2	from	2017-03-01
629	3	to	2017-06-14
630	0	collection	LCTSC
630	1	site	MGH
630	2	from	2017-05-29
630	3	to	2017-06-14
631	0	collection	LCTSC
632	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.7221.4598.189908156232039679891124105314
633	0	collection	LCTSC
634	0	study_instance_uid	1.3.6.1.4.1.14519.5.2.1.7014.4598.492964872630309412859177308186
635	0	collection	LCTSC
636	0	project_name	LCTSC
636	1	site_name	MGH
637	0	collection	LCTSC
637	1	site	MGH
637	2	from	2017-05-29
637	3	to	2017-06-14
639	0	scan_id	23
640	0	scan_id	23
642	0	collection	HNSCC
645	0	CollectionLike	Phanto%
646	0	collection	Phantom FDA
646	1	from	2017-05-12
646	2	to	2017-06-13
647	0	collection	Phantom FDA
647	1	from	2016-01-01
647	2	to	2017-06-13
648	0	user	bbennett
648	1	from	2017-06-13
648	2	to	2017-06-14
658	0	collection	HNSCC
659	0	collection	Lung-Fused-CT-Pathology
659	1	from	2017-06-12
659	2	to	2017-06-14
660	0	collection	HNSCC
661	0	from	2017-06-12
661	1	to	2017-06-14
662	0	from	2017-06-13
662	1	to	2017-06-14
663	0	collection	HNSCC
663	1	from	2017-06-09
663	2	to	2017-06-10
664	0	collection	HNSCC
664	1	from	2017-06-09
664	2	to	2017-06-10
665	0	collection	HNSCC
665	1	from	2017-06-09
665	2	to	2017-06-10
668	0	scan_id	21
669	0	scan_id	21
\.


--
-- Data for Name: popup_buttons; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY popup_buttons (popup_button_id, name, object_class, btn_col, is_full_table, btn_name) FROM stdin;
2	SopsDupsInDifferentSeriesByCollectionSite	Posda::PopupImageViewer	file_id	f	View
3	SopsDupsInDifferentSeriesByCollectionSite	Posda::PopupCompare	sop_instance_uid	f	Compare
1	%EditResults%	Posda::PopupCompareFilesPath	\N	f	Compare Files
4	DupSopsByCollectionSiteDateRange	Posda::PopupCompare	sop_instance_uid	f	Compare
5	DuplicateFilesBySop	Posda::PopupCompare	sop_instance_uid	f	Compare
6	DuplicateFilesBySop	Posda::PopupCompare	sop_instance_uid	f	Compare
7	DuplicateFilesBySop	Posda::PopupCompare	sop_instance_uid	f	Compare
8	%	Quince	file_id	f	view
9	GetSimilarDupContourCounts	Posda::PopupCompare	\N	t	Compare
10	DistinctSeriesByCollection	Posda::ProcessPopup	\N	t	SimplePhiScan
\.


--
-- Name: popup_buttons_popup_button_id_seq; Type: SEQUENCE SET; Schema: public; Owner: quasar
--

SELECT pg_catalog.setval('popup_buttons_popup_button_id_seq', 1, false);


--
-- Name: popup_buttons_popup_button_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: posda
--

SELECT pg_catalog.setval('popup_buttons_popup_button_id_seq1', 10, true);


--
-- Data for Name: queries; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY queries (name, query, args, columns, tags, schema, description) FROM stdin;
ActiveQueriesOld	select\n  datname as db_name, procpid as pid,\n  usesysid as user_id, usename as user,\n  waiting, now() - xact_start as since_xact_start,\n  now() - query_start as since_query_start,\n  now() - backend_start as since_back_end_start,\n  current_query\nfrom\n  pg_stat_activity\nwhere\n  datname = ?\n	{db_name}	{db_name,pid,user_id,user,waiting,since_xact_start,since_query_start,since_back_end_start,current_query}	{postgres_status}	posda_files	Show active queries for a database\nWorks for PostgreSQL 8.4.20 (Current Linux)\n
AllHiddenSubjects	select\n  distinct patient_id, project_name, site_name,\n  count(*) as num_files\nfrom\n  file_patient natural join ctp_file\nwhere patient_id in (\n    select distinct patient_id \n    from file_patient\n  except \n    select patient_id \n    from\n      file_patient natural join ctp_file \n    where\n      visibility is null\n) group by patient_id, project_name, site_name\norder by project_name, site_name, patient_id;\n	{}	{patient_id,project_name,site_name,num_files}	{FindSubjects}	posda_files	Find All Subjects which have only hidden files\n
AllPixelInfo	select\n  f.file_id as file_id, root_path || '/' || rel_path as file,\n  file_offset, size, modality,\n  bits_stored, bits_allocated, pixel_representation, number_of_frames,\n  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation\nfrom\n  file_image f natural join image natural join unique_pixel_data\n  natural join file_series\n  join pixel_location pl using(unique_pixel_data_id), \n  file_location fl natural join file_storage_root\nwhere\n  pl.file_id = fl.file_id\n  and f.file_id = pl.file_id\n  and f.file_id in (\n  select distinct file_id\n  from ctp_file\n  where visibility is null\n)\n	{}	{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,modality}	{}	posda_files	Get pixel descriptors for all files\n
AllPixelInfoByBitDepth	select\n  f.file_id as file_id, root_path || '/' || rel_path as file,\n  file_offset, size, modality,\n  bits_stored, bits_allocated, pixel_representation, number_of_frames,\n  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation\nfrom\n  file_image f natural join image natural join unique_pixel_data\n  natural join file_series\n  join pixel_location pl using(unique_pixel_data_id), \n  file_location fl natural join file_storage_root\nwhere\n  pl.file_id = fl.file_id\n  and f.file_id = pl.file_id\n  and f.file_id in (\n  select distinct file_id\n  from\n    ctp_file natural join file_image natural join image\n  where visibility is null and bits_allocated = ?\n)\n	{bits_allocated}	{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,modality}	{}	posda_files	Get pixel descriptors for all files\n
AllPixelInfoByModality	select\n  f.file_id as file_id, root_path || '/' || rel_path as file,\n  file_offset, size, modality,\n  bits_stored, bits_allocated, pixel_representation, number_of_frames,\n  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation\nfrom\n  file_image f natural join image natural join unique_pixel_data\n  natural join file_series\n  join pixel_location pl using(unique_pixel_data_id), \n  file_location fl natural join file_storage_root\nwhere\n  pl.file_id = fl.file_id\n  and f.file_id = pl.file_id\n  and f.file_id in (\n  select distinct file_id\n  from\n    ctp_file natural join file_series \n  where visibility is null and modality = ?\n)\n	{bits_allocated}	{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,modality}	{}	posda_files	Get pixel descriptors for all files\n
AllPixelInfoByPhotometricInterp	select\n  f.file_id as file_id, root_path || '/' || rel_path as file,\n  file_offset, size, modality,\n  bits_stored, bits_allocated, pixel_representation, number_of_frames,\n  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation\nfrom\n  file_image f natural join image natural join unique_pixel_data\n  natural join file_series\n  join pixel_location pl using(unique_pixel_data_id), \n  file_location fl natural join file_storage_root\nwhere\n  pl.file_id = fl.file_id\n  and f.file_id = pl.file_id\n  and f.file_id in (\n  select distinct file_id\n  from\n    ctp_file natural join file_image natural join image\n  where visibility is null and photometric_interpretation = ?\n)\n	{bits_allocated}	{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,modality}	{}	posda_files	Get pixel descriptors for all files\n
AllSopsReceivedBetweenDates	select\n   distinct project_name, site_name, patient_id,\n   study_instance_uid, series_instance_uid, count(*) as num_sops,\n   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\nfrom (\n  select \n    distinct project_name, site_name, patient_id,\n    study_instance_uid, series_instance_uid, sop_instance_uid,\n    count(*) as num_files, sum(num_uploads) as num_uploads,\n    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\n  from (\n    select\n      distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, count(*) as num_uploads, max(import_time) as last_loaded,\n         min(import_time) as first_loaded\n    from (\n      select\n        distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, import_time\n      from\n        ctp_file natural join file_patient natural join\n        file_study natural join file_series natural join\n        file_sop_common natural join file_import natural join\n        import_event\n      where\n        visibility is null and sop_instance_uid in (\n          select distinct sop_instance_uid\n          from \n            file_import natural join import_event natural join file_sop_common\n          where import_time > ? and import_time < ?\n        )\n      ) as foo\n    group by\n      project_name, site_name, patient_id, study_instance_uid, \n      series_instance_uid, sop_instance_uid, file_id\n  )as foo\n  group by \n    project_name, site_name, patient_id, study_instance_uid, \n    series_instance_uid, sop_instance_uid\n) as foo\ngroup by \n  project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid\n	{start_time,end_time}	{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,first_loaded,last_loaded}	{receive_reports}	posda_files	Series received between dates regardless of duplicates\n
AllSopsReceivedBetweenDatesByCollection	select\n   distinct project_name, site_name, patient_id,\n   study_instance_uid, series_instance_uid, count(*) as num_sops,\n   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\nfrom (\n  select \n    distinct project_name, site_name, patient_id,\n    study_instance_uid, series_instance_uid, sop_instance_uid,\n    count(*) as num_files, sum(num_uploads) as num_uploads,\n    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\n  from (\n    select\n      distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, count(*) as num_uploads, max(import_time) as last_loaded,\n         min(import_time) as first_loaded\n    from (\n      select\n        distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, import_time\n      from\n        ctp_file natural join file_patient natural join\n        file_study natural join file_series natural join\n        file_sop_common natural join file_import natural join\n        import_event\n      where\n        visibility is null and sop_instance_uid in (\n          select distinct sop_instance_uid\n          from \n            file_import natural join import_event natural join file_sop_common\n            natural join ctp_file\n          where import_time > ? and import_time < ? and\n            project_name = ? and visibility is null\n        )\n      ) as foo\n    group by\n      project_name, site_name, patient_id, study_instance_uid, \n      series_instance_uid, sop_instance_uid, file_id\n  )as foo\n  group by \n    project_name, site_name, patient_id, study_instance_uid, \n    series_instance_uid, sop_instance_uid\n) as foo\ngroup by \n  project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid\n	{start_time,end_time,collection}	{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,first_loaded,last_loaded}	{receive_reports}	posda_files	Series received between dates regardless of duplicates\n
DistinctSeriesBySubjectIntake	select\n  distinct s.series_instance_uid, modality, count(*) as num_images\nfrom\n  general_image i, general_series s,\n  trial_data_provenance tdp\nwhere\n  s.general_series_pk_id = i.general_series_pk_id and\n  i.patient_id = ? and i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and\n  tdp.dp_site_name = ?\ngroup by series_instance_uid, modality\n	{subject_id,project_name,site_name}	{series_instance_uid,modality,num_images}	{by_subject,find_series,intake}	intake	Get Series in A Collection, Site, Subject\n
AllSubjectsWithNoStatus	select\n  distinct patient_id, project_name, site_name,\n  count(*) as num_files\nfrom\n  file_patient natural join ctp_file\nwhere\n  patient_id in (\n    select \n      distinct patient_id\n    from\n      file_patient p\n    where\n       not exists (\n         select\n           patient_id\n         from\n            patient_import_status s\n         where\n            p.patient_id = s.patient_id\n       )\n  ) \n  and visibility is null\ngroup by patient_id, project_name, site_name\norder by project_name, site_name, patient_id\n	{}	{patient_id,project_name,site_name,num_files}	{FindSubjects,PatientStatus}	posda_files	All Subjects With No Patient Import Status\n
AllValuesByElementSig	select distinct value, vr, element_signature, equipment_signature, count(*)\nfrom (\nselect\n  distinct series_instance_uid, element_signature, value, vr,\n  equipment_signature\nfrom\n  scan_event natural join series_scan\n  natural join scan_element natural join element_signature\n  natural join equipment_signature\n  natural join seen_value\nwhere\n  scan_event_id = ? and\n  element_signature = ?\n) as foo\ngroup by value, element_signature, vr, equipment_signature\norder by value, element_signature, vr, equipment_signature\n	{scan_id,tag_signature}	{value,vr,element_signature,equipment_signature,count}	{tag_usage}	posda_phi	List of values seen in scan by ElementSignature with VR and count\n
AllVisibleSubjects	select\n  distinct patient_id,\n  patient_import_status as status,\n  project_name, site_name,\n  count(*) as num_files\nfrom\n  file_patient natural join ctp_file natural join patient_import_status\nwhere\n  patient_id in (\n    select patient_id \n    from\n      file_patient natural join ctp_file \n    where\n      visibility is null\n  ) and\n  visibility is null\ngroup by patient_id, status, project_name, site_name\norder by project_name, status, site_name, patient_id;\n	{}	{patient_id,status,project_name,site_name,num_files}	{FindSubjects,PatientStatus}	posda_files	Find All Subjects which have at least one visible file\n
AllVisibleSubjectsByCollection	select\n  distinct patient_id,\n  patient_import_status as status,\n  project_name, site_name,\n  count(*) as num_files\nfrom\n  file_patient natural join ctp_file natural join patient_import_status\nwhere\n  patient_id in (\n    select patient_id \n    from\n      file_patient natural join ctp_file \n    where\n      project_name = ? and\n      visibility is null\n  ) and\n  visibility is null\ngroup by patient_id, status, project_name, site_name\norder by project_name, status, site_name, patient_id;\n	{collection}	{patient_id,status,project_name,site_name,num_files}	{FindSubjects,PatientStatus}	posda_files	Find All Subjects which have at least one visible file\n
AllVrsByElementSig	select distinct vr, element_signature, equipment_signature, count(*)\nfrom (\nselect\n  distinct series_instance_uid, element_signature, vr,\n  equipment_signature\nfrom\n  scan_event natural join series_scan\n  natural join scan_element natural join element_signature\n  natural join equipment_signature\nwhere\n  scan_event_id = ? and\n  element_signature = ?\n) as foo\ngroup by element_signature, vr, equipment_signature\norder by element_signature, vr, equipment_signature\n	{scan_id,tag_signature}	{vr,element_signature,equipment_signature,count}	{tag_usage}	posda_phi	List of values seen in scan by ElementSignature with VR and count\n
AverageSecondsPerFile	select avg(seconds_per_file) from (\n  select (send_ended - send_started)/number_of_files as seconds_per_file \n  from dicom_send_event where send_ended is not null and number_of_files > 0\n  and send_started > ? and send_ended < ?\n) as foo\n	{from_date,to_date}	{avg}	{send_to_intake}	posda_files	Average Time to send a file between times\n
CountsByCollection	select\n  distinct\n    patient_id, image_type, modality, study_date, study_description,\n    series_description, study_instance_uid, series_instance_uid,\n    manufacturer, manuf_model_name, software_versions,\n    count(distinct sop_instance_uid) as num_sops,\n    count(distinct file_id) as num_files\nfrom\n  ctp_file join file_patient using(file_id)\n  join file_series using(file_id)\n  join file_sop_common using(file_id)\n  join file_study using(file_id)\n  join file_equipment using(file_id)\n  left join file_image using(file_id)\n  left join image using (image_id)\nwhere\n  project_name = ? and visibility is null\ngroup by\n  patient_id, image_type, modality, study_date, study_description,\n  series_description, study_instance_uid, series_instance_uid,\n  manufacturer, manuf_model_name, software_versions\norder by\n  patient_id, study_instance_uid, series_instance_uid, image_type,\n  modality, study_date, study_description,\n  series_description,\n  manufacturer, manuf_model_name, software_versions\n	{collection}	{patient_id,image_type,modality,study_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files}	{counts}	posda_files	Counts query by Collection\n
GetInsertedSendId	select currval('dicom_send_event_dicom_send_event_id_seq') as id\n	{}	{id}	{NotInteractive,SeriesSendEvent}	posda_files	Get dicom_send_event_id after creation\nFor use in scripts.\nNot meant for interactive use\n
GetSimpleValueSeen	select\n  value_seen_id as id\nfrom \n  value_seen\nwhere\n  value = ?	{value}	{id}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Get value seen if exists
CountsByCollectionSite	select\n  distinct\n    patient_id, image_type, modality, study_date, study_description,\n    series_description, study_instance_uid, series_instance_uid,\n    manufacturer, manuf_model_name, software_versions,\n    count(distinct sop_instance_uid) as num_sops,\n    count(distinct file_id) as num_files\nfrom\n  ctp_file join file_patient using(file_id)\n  join file_series using(file_id)\n  join file_sop_common using(file_id)\n  join file_study using(file_id)\n  join file_equipment using(file_id)\n  left join file_image using(file_id)\n  left join image using (image_id)\nwhere\n  project_name = ? and site_name = ? and visibility is null\ngroup by\n  patient_id, image_type, modality, study_date, study_description,\n  series_description, study_instance_uid, series_instance_uid,\n  manufacturer, manuf_model_name, software_versions\norder by\n  patient_id, study_instance_uid, series_instance_uid, image_type,\n  modality, study_date, study_description,\n  series_description,\n  manufacturer, manuf_model_name, software_versions\n	{collection,site}	{patient_id,image_type,modality,study_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files}	{counts}	posda_files	Counts query by Collection, Site\n
CountsByCollectionSiteSubject	select\n  distinct\n    patient_id, image_type, dicom_file_type, modality,\n    study_date, study_description,\n    series_description, study_instance_uid, series_instance_uid,\n    manufacturer, manuf_model_name, software_versions,\n    count(distinct sop_instance_uid) as num_sops,\n    count(distinct file_id) as num_files\nfrom\n  ctp_file join file_patient using(file_id)\n  join file_series using(file_id)\n  join file_sop_common using(file_id)\n  join dicom_file using(file_id)\n  join file_study using(file_id)\n  join file_equipment using(file_id)\n  left join file_image using(file_id)\n  left join image using (image_id)\nwhere\n  project_name = ? and site_name = ? and patient_id = ?\n  and visibility is null\ngroup by\n  patient_id, image_type, dicom_file_type, modality,\n  study_date, study_description,\n  series_description, study_instance_uid, series_instance_uid,\n  manufacturer, manuf_model_name, software_versions\norder by\n  patient_id, study_instance_uid, series_instance_uid, image_type,\n  dicom_file_type, modality, study_date, study_description,\n  series_description,\n  manufacturer, manuf_model_name, software_versions\n	{collection,site,patient_id}	{patient_id,image_type,dicom_file_type,modality,study_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files}	{counts}	posda_files	Counts query by Collection, Site, Subject\n
CreateFileSend	insert into dicom_file_send(\n  dicom_send_event_id, file_path, status, file_id_sent\n) values (\n  ?, ?, ?, ?\n)\n	{id,path,status,file_id}	\N	{NotInteractive,SeriesSendEvent}	posda_files	Add a file send row\nFor use in scripts.\nNot meant for interactive use\n
DatabaseSize	SELECT d.datname AS Name,  pg_catalog.pg_get_userbyid(d.datdba) AS Owner,\n    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')\n        THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))\n        ELSE 'No Access'\n    END AS SIZE\nFROM pg_catalog.pg_database d\n    ORDER BY\n    CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')\n        THEN pg_catalog.pg_database_size(d.datname)\n        ELSE NULL\n    END DESC -- nulls first\n    LIMIT 20;\n	{}	{Name,Owner,Size}	{postgres_status}	posda_files	Show active queries for a database\nWorks for PostgreSQL 9.4.5 (Current Mac)\n
DatesOfUploadByCollectionSite	select distinct date_trunc as date, count(*) as num_uploads from (\n select \n  date_trunc('day', import_time),\n  file_id\nfrom file_import natural join import_event\n  natural join ctp_file\nwhere project_name = ? and site_name = ? \n) as foo\ngroup by date\norder by date\n	{collection,site}	{date,num_uploads}	{receive_reports}	posda_files	Show me the dates with uploads for Collection from Site\n
DatesOfUploadByCollectionSiteVisible	select distinct date_trunc as date, count(*) as num_uploads from (\n select \n  date_trunc('day', import_time),\n  file_id\nfrom file_import natural join import_event natural join file_sop_common\n  natural join ctp_file\nwhere project_name = ? and site_name = ? and visibility is null\n) as foo\ngroup by date\norder by date\n	{collection,site}	{date,num_uploads}	{receive_reports}	posda_files	Show me the dates with uploads for Collection from Site\n
DiskSpaceByCollection	select\n  distinct project_name as collection, sum(size) as total_bytes\nfrom\n  ctp_file natural join file\nwhere\n  file_id in (\n  select distinct file_id\n  from ctp_file\n  where project_name = ?\n  )\ngroup by project_name\n	{collection}	{collection,total_bytes}	{by_collection,posda_files,storage_used}	posda_files	Get disk space used by collection\n
DiskSpaceByCollectionSummary	select\n  distinct project_name as collection, sum(size) as total_bytes\nfrom\n  ctp_file natural join file\nwhere\n  file_id in (\n  select distinct file_id\n  from ctp_file\n  )\ngroup by project_name\norder by total_bytes\n	{}	{collection,total_bytes}	{by_collection,posda_files,storage_used,summary}	posda_files	Get disk space used for all collections\n
FilesByScanValueTag	select\n  distinct series_instance_uid,\n  series_scanned_file as file, \n  element_signature, value, sequence_level,\n  item_number\nfrom\n  scan_event natural join series_scan natural join seen_value\n  natural join element_signature natural join \n  scan_element natural left join sequence_index\nwhere\n  scan_event_id = ? and value = ? and element_signature = ?\norder by series_instance_uid, file\n	{scan_id,value,tag}	{series_instance_uid,file,element_signature,value,sequence_level,item_number}	{tag_usage,phi_review}	posda_phi	Find out where specific value, tag combinations occur in a scan\n
DistinctSeriesBySubject	select distinct series_instance_uid, modality, count(*)\nfrom (\nselect distinct series_instance_uid, sop_instance_uid, modality from (\nselect\n   distinct series_instance_uid, modality, sop_instance_uid,\n   file_id\n from file_series natural join file_sop_common\n   natural join file_patient natural join ctp_file\nwhere\n  patient_id = ? and project_name = ? \n  and site_name = ? and visibility is null)\nas foo\ngroup by series_instance_uid, sop_instance_uid, modality)\nas foo\ngroup by series_instance_uid, modality\n	{subject_id,project_name,site_name}	{series_instance_uid,modality,count}	{by_subject,find_series}	posda_files	Get Series in A Collection, Site, Subject\n
DistinctSopsInCollection	select distinct sop_instance_uid\nfrom\n  file_sop_common\nwhere file_id in (\n  select\n    distinct file_id\n  from\n    ctp_file\n  where\n    project_name = ? and visibility is null\n)\norder by sop_instance_uid\n	{collection}	{sop_instance_uid}	{by_collection,posda_files,sops}	posda_files	Get Distinct SOPs in Collection with number files\nOnly visible files\n
DistinctSopsInCollectionByStorageClass	select distinct sop_instance_uid, rel_path\nfrom\n  file_sop_common natural join file_location natural join file_storage_root\nwhere file_id in (\n  select\n    distinct file_id\n  from\n    ctp_file natural join file_location natural join file_storage_root\n  where\n    project_name = ? and visibility is null and storage_class = ?\n) and current\norder by sop_instance_uid\n	{collection,storage_class}	{sop_instance_uid,rel_path}	{by_collection,posda_files,sops}	posda_files	Get Distinct SOPs in Collection with number files\nOnly visible files\n
DistinctSopsInCollectionIntake	select\n  distinct i.sop_instance_uid\nfrom\n  general_image i,\n  trial_data_provenance tdp\nwhere\n  i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ?\norder by sop_instance_uid\n	{collection}	{sop_instance_uid}	{by_collection,intake,sops}	intake	Get Distinct SOPs in Collection with number files\nOnly visible files\n
DistinctSopsInCollectionIntakeWithFile	select\n  distinct i.sop_instance_uid, i.dicom_file_uri\nfrom\n  general_image i,\n  trial_data_provenance tdp\nwhere\n  i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ?\norder by sop_instance_uid\n	{collection}	{sop_instance_uid,dicom_file_uri}	{by_collection,files,intake,sops}	intake	Get Distinct SOPs in Collection with number files\nOnly visible files\n
DistinctSopsInSeries	select distinct sop_instance_uid, count(*)\nfrom file_sop_common\nwhere file_id in (\n  select\n    distinct file_id\n  from\n    file_series natural join ctp_file\n  where\n    series_instance_uid = ? and visibility is null\n)\ngroup by sop_instance_uid\norder by count desc\n	{series_instance_uid}	{sop_instance_uid,count}	{by_series_instance_uid,duplicates,posda_files,sops}	posda_files	Get Distinct SOPs in Series with number files\nOnly visible filess\n
DistinctUnhiddenFilesInSeries	select\n  distinct file_id\nfrom\n  file_series natural join file_sop_common natural join ctp_file\nwhere\n  series_instance_uid = ? and visibility is null\n	{series_instance_uid}	{file_id}	{by_series_instance_uid,file_ids,posda_files}	posda_files	Get Distinct Unhidden Files in Series\n
DistinctValuesByTagWithFileCount	select distinct element_signature, value, count(*) as num_files\nfrom (\nselect\n  distinct series_instance_uid,\n  series_scanned_file as file, \n  element_signature, value\nfrom\n  scan_event natural join series_scan natural join seen_value\n  natural join element_signature natural join \n  scan_element natural left join sequence_index\nwhere\n  element_signature = ?\norder by series_instance_uid, file, value\n) as foo\ngroup by element_signature, value\n	{tag}	{element_signature,value,num_files}	{tag_usage}	posda_phi	Distinct values for a tag with file count\n
DupSopCountsByCSS	select\n  distinct sop_instance_uid, min, max, count\nfrom (\n  select\n    distinct sop_instance_uid, min(file_id),\n    max(file_id),count(*)\n  from (\n    select\n      distinct sop_instance_uid, file_id\n    from\n      file_sop_common \n    where sop_instance_uid in (\n      select\n        distinct sop_instance_uid\n      from\n        file_sop_common natural join ctp_file\n        natural join file_patient\n      where\n        project_name = ? and site_name = ? \n        and patient_id = ? and visibility is null\n    )\n  ) as foo natural join ctp_file\n  where visibility is null\n  group by sop_instance_uid\n)as foo where count > 1\n	{collection,site,subject}	{sop_instance_uid,min,max,count}	{}	posda_files	Counts of DuplicateSops By Collection, Site, Subject\n
DupSopsReceivedBetweenDates	select\n   distinct project_name, site_name, patient_id,\n   study_instance_uid, series_instance_uid, count(*) as num_sops,\n   sum(num_files) as num_files, sum(num_uploads) as num_uploads,\n    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\nfrom (\n  select \n    distinct project_name, site_name, patient_id,\n    study_instance_uid, series_instance_uid, sop_instance_uid,\n    count(*) as num_files, sum(num_uploads) as num_uploads,\n    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\n  from (\n    select\n      distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, count(*) as num_uploads, max(import_time) as last_loaded,\n         min(import_time) as first_loaded\n    from (\n      select\n        distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, import_time\n      from\n        ctp_file natural join file_patient natural join\n        file_study natural join file_series natural join\n        file_sop_common natural join file_import natural join\n        import_event\n      where\n        visibility is null and sop_instance_uid in (\n          select distinct sop_instance_uid\n          from \n            file_import natural join import_event natural join file_sop_common\n          where import_time > ? and import_time < ?\n        )\n      ) as foo\n    group by\n      project_name, site_name, patient_id, study_instance_uid, \n      series_instance_uid, sop_instance_uid, file_id\n  )as foo\n  group by \n    project_name, site_name, patient_id, study_instance_uid, \n    series_instance_uid, sop_instance_uid\n) as foo\nwhere num_uploads > 1\ngroup by \n  project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid\n	{start_time,end_time}	{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,num_files,num_uploads,first_loaded,last_loaded}	{receive_reports}	posda_files	Series received between dates with duplicate sops\n
DupSopsReceivedBetweenDatesByCollection	select\n   distinct project_name, site_name, patient_id,\n   study_instance_uid, series_instance_uid, count(*) as num_sops,\n   sum(num_files) as num_files, sum(num_uploads) as num_uploads,\n    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\nfrom (\n  select \n    distinct project_name, site_name, patient_id,\n    study_instance_uid, series_instance_uid, sop_instance_uid,\n    count(*) as num_files, sum(num_uploads) as num_uploads,\n    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\n  from (\n    select\n      distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, count(*) as num_uploads, max(import_time) as last_loaded,\n         min(import_time) as first_loaded\n    from (\n      select\n        distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, import_time\n      from\n        ctp_file natural join file_patient natural join\n        file_study natural join file_series natural join\n        file_sop_common natural join file_import natural join\n        import_event\n      where\n        visibility is null and sop_instance_uid in (\n          select distinct sop_instance_uid\n          from \n            file_import natural join import_event natural join file_sop_common\n             natural join ctp_file\n          where import_time > ? and import_time < ?\n            and project_name = ? and visibility is null\n        )\n      ) as foo\n    group by\n      project_name, site_name, patient_id, study_instance_uid, \n      series_instance_uid, sop_instance_uid, file_id\n  )as foo\n  group by \n    project_name, site_name, patient_id, study_instance_uid, \n    series_instance_uid, sop_instance_uid\n) as foo\nwhere num_uploads > 1\ngroup by \n  project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid\n	{start_time,end_time,collection}	{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,num_files,num_uploads,first_loaded,last_loaded}	{receive_reports}	posda_files	Series received between dates with duplicate sops\n
GetPrivateTagFeaturesBySignature	select\n  pt_consensus_name as name,\n  pt_consensus_vr as vr,\n  pt_consensus_disposition as disposition\nfrom pt\nwhere pt_signature = ?\n	{signature}	{name,vr,disposition}	{DispositionReport,NotInteractive}	posda_private_tag	Get the relevant features of a private tag by signature\nUsed in DispositionReport.pl - not for interactive use\n
DuplicateDownloadsByCollection	select distinct patient_id, series_instance_uid, count(*)\nfrom file_series natural join file_patient\nwhere file_id in (\n  select file_id from (\n    select\n      distinct file_id, count(*)\n    from file_import\n    where file_id in (\n      select\n        distinct file_id\n      from \n        file_patient natural join ctp_file\n      where\n        project_name = ? \n        and site_name = ? and visibility is null\n    )\n    group by file_id\n  ) as foo\n  where count > 1\n)\ngroup by patient_id, series_instance_uid\norder by patient_id\n	{project_name,site_name}	{series_instance_uid,count}	{by_collection,duplicates,find_series}	posda_files	Number of files for a subject which have been downloaded more than once\n
DuplicateDownloadsBySubject	select count(*) from (\n  select\n    distinct file_id, count(*)\n  from file_import\n  where file_id in (\n    select\n      distinct file_id\n    from \n      file_patient natural join ctp_file\n    where\n      patient_id = ? and project_name = ? \n      and site_name = ? and visibility is null\n  )\n  group by file_id\n) as foo\nwhere count > 1\n	{subject_id,project_name,site_name}	{count}	{by_subject,duplicates,find_series}	posda_files	Number of files for a subject which have been downloaded more than once\n
DuplicateSOPInstanceUIDs	select\n  sop_instance_uid, min(file_id) as first,\n  max(file_id) as last, count(*)\nfrom file_sop_common\nwhere sop_instance_uid in (\n  select distinct sop_instance_uid from (\n    select distinct sop_instance_uid, count(*) from (\n      select distinct file_id, sop_instance_uid \n      from\n        ctp_file natural join file_sop_common\n        natural join file_patient\n      where project_name = ? and site_name = ? and patient_id = ?\n    ) as foo natural join ctp_file\n    where visibility is null\n    group by sop_instance_uid order by count desc\n  ) as foo where count > 1\n) group by sop_instance_uid;\n	{collection,site,subject}	{sop_instance_uid,first,last,count}	{duplicates}	posda_files	Return a count of duplicate SOP Instance UIDs\n
DuplicateSOPInstanceUIDsByCollectionWithoutHidden1	select\n  distinct project_name as collection,\n  site_name as site, patient_id,\n  study_instance_uid, series_instance_uid\nfrom file_sop_common natural join ctp_file natural join file_patient\n  natural join file_study natural join file_series\nwhere sop_instance_uid in (\n  select distinct sop_instance_uid from (\n    select distinct sop_instance_uid, count(*) from (\n      select distinct file_id, sop_instance_uid \n      from\n        ctp_file natural join file_sop_common\n        natural join file_patient\n    ) as foo natural join ctp_file\n    group by sop_instance_uid order by count desc\n  ) as foo where count > 1\n) group by project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid\n	{}	{collection,site,patient_id,study_instance_uid,series_instance_uid}	{receive_reports}	posda_files	Return a count of visible duplicate SOP Instance UIDs\n
DuplicateSOPInstanceUIDsGlobalWithHidden	select distinct collection, site, patient_id, count(*)\nfrom (\nselect \n  distinct collection, site, patient_id, sop_instance_uid, count(*)\n  as dups\nfrom (\nselect\n  distinct project_name as collection,\n  site_name as site, patient_id,\n  study_instance_uid, series_instance_uid, sop_instance_uid, file_id\nfrom file_sop_common natural join ctp_file natural join file_patient\n  natural join file_study natural join file_series\nwhere sop_instance_uid in (\n  select distinct sop_instance_uid from (\n    select distinct sop_instance_uid, count(*) from (\n      select distinct file_id, sop_instance_uid \n      from\n        ctp_file natural join file_sop_common\n        natural join file_patient\n    ) as foo\n    group by sop_instance_uid order by count desc\n  ) as foo where count > 1\n) group by project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid, sop_instance_uid, file_id\n) as foo\ngroup by collection, site, patient_id, sop_instance_uid\n) as foo where dups > 1\ngroup by collection, site, patient_id\norder by collection, site, patient_id\n	{}	{collection,site,patient_id,count}	{receive_reports}	posda_files	Return a report of duplicate SOP Instance UIDs ignoring visibility\n
FilesWithIndicesByElementScanId	select\n  distinct series_instance_uid,\n  series_scanned_file as file, \n  element_signature, sequence_level,\n  item_number\nfrom\n  series_scan natural join element_signature natural join \n  scan_element natural left join sequence_index\nwhere\n  scan_element_id = ?\n	{scan_element_id}	{series_instance_uid,file,element_signature,sequence_level,item_number}	{tag_usage}	posda_phi	Find out where specific value, tag combinations occur in a scan\n
GetSlopeIntercept	select\n  slope, intercept, si_units\nfrom\n  file_slope_intercept natural join slope_intercept\nwhere\n  file_id = ?\n	{file_id}	{slope,intercept,si_units}	{by_file_id,posda_files,slope_intercept}	posda_files	Get a Slope, Intercept for a particular file \n
CreateSimpleValueSeen	insert into value_seen(\nvalue\n)values(?)	{value}	{}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Create a new Simple Value Seen
GetSimpleValueSeenId	select currval('value_seen_value_seen_id_seq') as id	{}	{id}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Get index of newly created value_seen
DuplicateSOPInstanceUIDsGlobalWithoutHidden	select\n  distinct project_name as collection,\n  site_name as site, patient_id,\n  study_instance_uid, series_instance_uid, sop_instance_uid, file_id\nfrom file_sop_common natural join ctp_file natural join file_patient\n  natural join file_study natural join file_series\nwhere visibility is null and sop_instance_uid in (\n  select distinct sop_instance_uid from (\n    select distinct sop_instance_uid, count(*) from (\n      select distinct file_id, sop_instance_uid \n      from\n        ctp_file natural join file_sop_common\n        natural join file_study natural join file_series\n        natural join file_patient\n      where visibility is null\n    ) as foo\n    group by sop_instance_uid order by count desc\n  ) as foo where count > 1\n) group by project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid, sop_instance_uid, file_id\n	{}	{collection,site,patient_id,study_instance_uid,series_instance_uid,sop_instance_uid,file_id}	{receive_reports}	posda_files	Return a report of visible duplicate SOP Instance UIDs\n
ElementScanIdByScanValueTag	select \n  distinct scan_element_id\nfrom\n  scan_element natural join element_signature\n  natural join series_scan natural join seen_value\n  natural join scan_event\nwhere\n  scan_event_id = ? and\n  value = ? and\n  element_signature = ?\n	{scan_id,value,tag}	{scan_element_id}	{tag_usage}	posda_phi	Find out where specific value, tag combinations occur in a scan\n
ElementsWithMultipleVRs	select element_signature, count from (\n  select element_signature, count(*)\n  from (\n    select\n      distinct element_signature, vr\n    from\n      scan_event natural join series_scan\n      natural join scan_element natural join element_signature\n      natural join equipment_signature\n    where\n      scan_event_id = ?\n  ) as foo\n  group by element_signature\n) as foo\nwhere count > 1\n	{scan_id}	{element_signature,count}	{tag_usage}	posda_phi	List of Elements with multiple VRs seen\n
EquipmentByPrivateTag	select distinct equipment_signature from (\nselect\n  distinct element_signature, equipment_signature\nfrom \n  equipment_signature natural join series_scan\n  natural join scan_element natural join element_signature\n  natural join scan_event\nwhere scan_event_id = ? and is_private ) as foo\nwhere element_signature = ?\norder by equipment_signature;\n	{scan_id,element_signature}	{equipment_signature}	{tag_usage}	posda_phi	Which equipment signatures for which private tags\n
EquipmentByValueSignature	select distinct value, vr, element_signature, equipment_signature, count(*)\nfrom (\nselect\n  distinct series_instance_uid, element_signature, value, vr,\n  equipment_signature\nfrom\n  scan_event natural join series_scan\n  natural join scan_element natural join element_signature\n  natural join equipment_signature\n  natural join seen_value\nwhere\n  scan_event_id = ? and\n  value = ? and\n  element_signature = ?\n) as foo\ngroup by value, element_signature, vr, equipment_signature\norder by value, element_signature, vr, equipment_signature\n	{scan_id,value,tag_signature}	{value,vr,element_signature,equipment_signature,count}	{tag_usage}	posda_phi	List of equipment, values seen in scan by VR with count\n
FilesAndLoadTimesInSeries	select\n  distinct sop_instance_uid, file_id, import_time\nfrom\n  file_sop_common natural join file_series\n  natural join file_import natural join import_event\nwhere\n  series_instance_uid = ?\norder by \n  sop_instance_uid, import_time, file_id\n	{series_instance_uid}	{sop_instance_uid,import_time,file_id}	{by_series}	posda_files	List of SOPs, files, and import times in a series\n
FilesByScanWithValue	select\n  distinct series_instance_uid,\n  series_scanned_file as file, \n  element_signature, value\nfrom\n  scan_event natural join series_scan natural join seen_value\n  natural join element_signature natural join \n  scan_element natural left join sequence_index\nwhere\n  scan_event_id = ? and element_signature = ?\norder by series_instance_uid, file, value\n	{scan_id,tag}	{series_instance_uid,file,element_signature,value}	{tag_usage}	posda_phi	Find out where specific value, tag combinations occur in a scan\n
FilesByTagWithValue	select\n  distinct series_instance_uid,\n  series_scanned_file as file, \n  element_signature, value\nfrom\n  scan_event natural join series_scan natural join seen_value\n  natural join element_signature natural join \n  scan_element natural left join sequence_index\nwhere\n  element_signature = ?\norder by series_instance_uid, file, value\n	{tag}	{series_instance_uid,file,element_signature,value}	{tag_usage}	posda_phi	Find out where specific value, tag combinations occur in a scan\n
FilesInCollectionSiteForSend	select\n  distinct file_id, root_path || '/' || rel_path as path, \n  xfer_syntax, sop_class_uid,\n  data_set_size, data_set_start, sop_instance_uid, digest\nfrom\n  file_location natural join file_storage_root\n  natural join dicom_file natural join ctp_file\n  natural join file_sop_common natural join file_series\n  natural join file_meta natural join file\nwhere\n  project_name = ? and site_name = ? and visibility is null\n	{collection,site}	{file_id,path,xfer_syntax,sop_class_uid,data_set_size,data_set_start,sop_instance_uid,digest}	{by_collection_site,find_files,for_send}	posda_files	Get everything you need to negotiate a presentation_context\nfor all files in a Collection Site\n
FilesInSeriesForSend	select\n  distinct file_id, root_path || '/' || rel_path as path, xfer_syntax, sop_class_uid,\n  data_set_size, data_set_start, sop_instance_uid, digest\nfrom\n  file_location natural join file_storage_root\n  natural join dicom_file natural join ctp_file\n  natural join file_sop_common natural join file_series\n  natural join file_meta natural join file\nwhere\n  series_instance_uid = ? and visibility is null\n	{series_instance_uid}	{file_id,path,xfer_syntax,sop_class_uid,data_set_size,data_set_start,sop_instance_uid,digest}	{SeriesSendEvent,by_series,find_files,for_send}	posda_files	Get everything you need to negotiate a presentation_context\nfor all files in a series\n
FindInconsistentSeriesExtended	select series_instance_uid from (\nselect distinct series_instance_uid, count(*) from (\n  select distinct\n    series_instance_uid, modality, series_number, laterality, series_date,\n    series_time, performing_phys, protocol_name, series_description,\n    operators_name, body_part_examined, patient_position,\n    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n    performed_procedure_step_start_date, performed_procedure_step_start_time,\n    performed_procedure_step_desc, performed_procedure_step_comments,\n    image_type, count(*)\n  from\n    file_series natural join ctp_file\n    left join file_image using(file_id)\n    left join image using(image_id)\n  where\n    project_name = ? and visibility is null\n  group by\n    series_instance_uid, image_type,\n    modality, series_number, laterality, series_date,\n    series_time, performing_phys, protocol_name, series_description,\n    operators_name, body_part_examined, patient_position,\n    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n    performed_procedure_step_start_date, performed_procedure_step_start_time,\n    performed_procedure_step_desc, performed_procedure_step_comments\n) as foo\ngroup by series_instance_uid\n) as foo\nwhere count > 1\n	{collection}	{series_instance_uid}	{consistency,find_series}	posda_files	Find Inconsistent Series Extended to include image type\n
FirstFilesInSeries	select root_path || '/' || rel_path as path\nfrom file_location natural join file_storage_root\nwhere file_id in (\nselect file_id from \n  (\n  select \n    distinct sop_instance_uid, min(file_id) as file_id\n  from \n    file_series natural join ctp_file \n    natural join file_sop_common\n  where \n    series_instance_uid = ?\n    and visibility is null\n  group by sop_instance_uid\n) as foo);\n	{series_instance_uid}	{path}	{by_series}	posda_files	First files uploaded by series\n
GetInfoForDupFilesByCollection	select\n  file_id, image_id, patient_id, study_instance_uid, series_instance_uid,\n   sop_instance_uid, modality\nfrom\n  file_patient natural join file_series natural join file_study\n  natural join file_sop_common natural join file_image\nwhere file_id in (\n  select file_id\n  from (\n    select image_id, file_id\n    from file_image\n    where image_id in (\n      select image_id\n      from (\n        select distinct image_id, count(*)\n        from (\n          select distinct image_id, file_id\n          from file_image\n          where file_id in (\n            select\n              distinct file_id\n              from ctp_file\n              where project_name = ? and visibility is null\n          )\n        ) as foo\n        group by image_id\n      ) as foo \n      where count > 1\n    )\n  ) as foo\n);\n	{collection}	{file_id,image_id,patient_id,study_instance_uid,series_instance_uid,sop_instance_uid,modality}	{}	posda_files	Get information related to duplicate files by collection\n
FirstFileInSeriesIntake	select\n  dicom_file_uri as path\nfrom\n  general_image\nwhere\n  series_instance_uid =  ?\nlimit 1\n	{series_instance_uid}	{path}	{by_series,intake,UsedInPhiSeriesScan}	intake	First files in series in Intake\n
GetPublicTagDispositionBySignature	select\n  disposition\nfrom public_tag_disposition\nwhere tag_name = ?\n	{signature}	{disposition}	{DispositionReport,NotInteractive}	posda_public_tag	Get the disposition of a public tag by signature\nUsed in DispositionReport.pl - not for interactive use\n
GetSeriesSignature	select distinct\n  dicom_file_type, modality|| ':' || coalesce(manufacturer, '<undef>') || ':' \n  || coalesce(manuf_model_name, '<undef>') ||\n  ':' || coalesce(software_versions, '<undef>') as signature,\n  count(distinct series_instance_uid) as num_series,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join file_equipment natural join ctp_file\n  natural join dicom_file\nwhere project_name = ?\ngroup by dicom_file_type, signature\n	{collection}	{dicom_file_type,signature,num_series,num_files}	{signature}	posda_files	Get a list of Series Signatures by Collection\n
GetSeriesWithSignature	select distinct\n  series_instance_uid, dicom_file_type, \n  modality|| ':' || coalesce(manufacturer, '<undef>') || ':' \n  || coalesce(manuf_model_name, '<undef>') ||\n  ':' || coalesce(software_versions, '<undef>') as signature,\n  count(distinct series_instance_uid) as num_series,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join file_equipment natural join ctp_file\n  natural join dicom_file\nwhere project_name = ? and visibility is null\ngroup by series_instance_uid, dicom_file_type, signature\n	{collection}	{series_instance_uid,dicom_file_type,signature,num_series,num_files}	{signature}	posda_files	Get a list of Series with Signatures by Collection\n
UpdateSendEvent	update dicom_send_event\n  set send_ended = now()\nwhere dicom_send_event_id = ?\n	{id}	\N	{NotInteractive,SeriesSendEvent}	posda_files	Update dicom_send_event_id after creation and completion of send\nFor use in scripts.\nNot meant for interactive use\n
FindInconsistentStudy	select distinct study_instance_uid from (\n  select distinct study_instance_uid, count(*) from (\n    select distinct\n      study_instance_uid, study_date, study_time,\n      referring_phy_name, study_id, accession_number,\n      study_description, phys_of_record, phys_reading,\n      admitting_diag\n    from\n      file_study natural join ctp_file\n    where\n      project_name = ? and visibility is null\n    group by\n      study_instance_uid, study_date, study_time,\n      referring_phy_name, study_id, accession_number,\n      study_description, phys_of_record, phys_reading,\n      admitting_diag\n  ) as foo\n  group by study_instance_uid\n) as foo\nwhere count > 1\n	{collection}	{study_instance_uid}	{by_study,consistency,study_consistency}	posda_files	Find Inconsistent Studies\n
GetWinLev	select\n  window_width, window_center, win_lev_desc, wl_index\nfrom\n  file_win_lev natural join window_level\nwhere\n  file_id = ?\norder by wl_index desc;\n	{file_id}	{window_width,window_center,win_lev_desc,wl_index}	{by_file_id,posda_files,window_level}	posda_files	Get a Window, Level(s) for a particular file \n
GlobalUnhiddenSOPDuplicatesSummary	select \n  distinct project_name as collection, site_name as site, patient_id,\n  study_instance_uid, series_instance_uid,\n  sop_instance_uid, min(import_time) as first_upload, max(import_time) as\n  last_upload, count(distinct file_id) as num_dup_sops,\n  count(*) as num_uploads from (\nselect\n  distinct project_name as collection,\n  site_name as site, patient_id,\n  study_instance_uid, series_instance_uid, sop_instance_uid, file_id\nfrom file_sop_common natural join ctp_file natural join file_patient\n  natural join file_study natural join file_series\nwhere visibility is null and sop_instance_uid in (\n  select distinct sop_instance_uid from (\n    select distinct sop_instance_uid, count(*) from (\n      select distinct file_id, sop_instance_uid \n      from\n        ctp_file natural join file_sop_common\n        natural join file_study natural join file_series\n        natural join file_patient\n      where visibility is null\n    ) as foo\n    group by sop_instance_uid order by count desc\n  ) as foo where count > 1\n) group by project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid, sop_instance_uid, file_id\n) as foo\nnatural join file_sop_common natural join file_series natural join file_study\nnatural join ctp_file natural join file_patient natural join file_import\nnatural join import_event\ngroup by project_name, site_name, patient_id,\n  study_instance_uid, series_instance_uid,\n  sop_instance_uid\norder by project_name, site_name, patient_id\n	{}	{collection,site,patient_id,study_instance_uid,series_instance_uid,sop_instance_uid,num_dup_sops,num_uploads,first_upload,last_upload}	{receive_reports}	posda_files	Return a report of visible duplicate SOP Instance UIDs\n
HideEarlyFilesCSP	update ctp_file set visibility = 'hidden' where file_id in (\n  select min as file_id\n  from (\n    select\n      distinct sop_instance_uid, min, max, count\n    from (\n      select\n        distinct sop_instance_uid, min(file_id),\n        max(file_id),count(*)\n      from (\n        select\n          distinct sop_instance_uid, file_id\n        from\n          file_sop_common \n        where sop_instance_uid in (\n          select\n            distinct sop_instance_uid\n          from\n            file_sop_common natural join ctp_file\n            natural join file_patient\n          where\n            project_name = ? and site_name = ? \n            and patient_id = ? and visibility is null\n        )\n      ) as foo natural join ctp_file\n      where visibility is null\n      group by sop_instance_uid\n    )as foo where count > 1\n  ) as foo\n);\n	{collection,site,subject}	\N	{}	posda_files	Hide earliest submission of a file:\n  Note:    uses sequencing of file_id to determine earliest\n           file, not import_time\n
HideSeriesNotLikeWithModality	update ctp_file set visibility = 'hidden'\nwhere file_id in (\n  select\n    file_id\n  from\n    file_series\n  where\n    series_instance_uid in (\n      select\n         distinct series_instance_uid\n      from (\n        select\n         distinct\n           file_id, series_instance_uid, series_description\n        from\n           ctp_file natural join file_series\n        where\n           modality = ? and project_name = ? and site_name = ?and \n           series_description not like ?\n      ) as foo\n    )\n  )\n	{modality,collection,site,description_not_matching}	\N	{Update,posda_files}	posda_files	Hide series not matching pattern by modality\n
ImageIdByFileId	select\n  distinct file_id, image_id\nfrom\n  file_image\nwhere\n  file_id = ?\n	{file_id}	{file_id,image_id}	{by_file_id,image_id,posda_files}	posda_files	Get image_id for file_id \n
StudiesInCollectionSite	select\n  distinct study_instance_uid\nfrom\n  file_study natural join ctp_file\nwhere\n  project_name = ? and site_name = ? and visibility is null\n	{project_name,site_name}	{study_instance_uid}	{find_studies}	posda_files	Get Studies in A Collection, Site\n
InsertSendEvent	insert into dicom_send_event(\n  destination_host, destination_port,\n  called_ae, calling_ae,\n  send_started, invoking_user,\n  reason_for_send, number_of_files,\n  is_series_send, series_to_send\n)values(\n  ?, ?,\n  ?, ?,\n  now(), ?,\n  ?, ?,\n  true, ?\n)\n	{host,port,called,calling,who,why,num_files,series}	\N	{NotInteractive,SeriesSendEvent}	posda_files	Create a DICOM Series Send Event\nFor use in scripts.\nNot meant for interactive use\n
IntakeImagesByCollectionSite	select\n  p.patient_id as PID,\n  s.modality as Modality,\n  i.sop_instance_uid as SopInstance,\n  t.study_date as StudyDate,\n  t.study_desc as StudyDescription,\n  s.series_desc as SeriesDescription,\n  s.series_number as SeriesNumber,\n  t.study_instance_uid as StudyInstanceUID,\n  s.series_instance_uid as SeriesInstanceUID,\n  q.manufacturer as Mfr,\n  q.manufacturer_model_name as Model,\n  q.software_versions\nfrom\n  general_image i,\n  general_series s,\n  study t,\n  patient p,\n  trial_data_provenance tdp,\n  general_equipment q\nwhere\n  i.general_series_pk_id = s.general_series_pk_id and\n  s.study_pk_id = t.study_pk_id and\n  s.general_equipment_pk_id = q.general_equipment_pk_id and\n  t.patient_pk_id = p.patient_pk_id and\n  p.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and\n  tdp.dp_site_name = ?\n	{collection,site}	{PID,Modality,SopInstance,ImageType,StudyDate,StudyDescription,SeriesDescription,SeriesNumber,StudyInstanceUID,SeriesInstanceUID,Mfr,Model,software_versions}	{intake}	intake	List of all Files Images By Collection, Site\n
PatientStatusCounts	select\n  distinct project_name as collection, patient_import_status as status,\n  count(distinct patient_id) as num_patients\nfrom\n  patient_import_status natural join file_patient natural join ctp_file\nwhere\n  visibility is null\ngroup by collection, status\norder by collection, status\n	{}	{collection,status,num_patients}	{FindSubjects,PatientStatus}	posda_files	Find All Subjects which have at least one visible file\n
IntakeFilesInSeries	select\n  dicom_file_uri as file_path\nfrom\n  general_image\nwhere\n  series_instance_uid = ?\n	{series_instance_uid}	{file_path}	{intake,used_in_simple_phi}	intake	List of all Series By Collection, Site on Intake\n
IntakeImagesByCollectionSiteSubj	select\n  p.patient_id as PID,\n  s.modality as Modality,\n  i.dicom_file_uri as FilePath,\n  i.sop_instance_uid as SopInstance,\n  t.study_date as StudyDate,\n  t.study_desc as StudyDescription,\n  s.series_desc as SeriesDescription,\n  s.series_number as SeriesNumber,\n  t.study_instance_uid as StudyInstanceUID,\n  s.series_instance_uid as SeriesInstanceUID,\n  q.manufacturer as Mfr,\n  q.manufacturer_model_name as Model,\n  q.software_versions\nfrom\n  general_image i,\n  general_series s,\n  study t,\n  patient p,\n  trial_data_provenance tdp,\n  general_equipment q\nwhere\n  i.general_series_pk_id = s.general_series_pk_id and\n  s.study_pk_id = t.study_pk_id and\n  s.general_equipment_pk_id = q.general_equipment_pk_id and\n  t.patient_pk_id = p.patient_pk_id and\n  p.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and\n  tdp.dp_site_name = ? and\n  p.patient_id = ?\n	{collection,site,patient_id}	{PID,Modality,SopInstance,FilePath}	{SymLink,intake}	intake	List of all Files Images By Collection, Site\n
IntakeSeriesByCollectionSite	select\n  p.patient_id as PID,\n  s.modality as Modality,\n  t.study_date as StudyDate,\n  t.study_desc as StudyDescription,\n  s.series_desc as SeriesDescription,\n  s.series_number as SeriesNumber,\n  t.study_instance_uid as StudyInstanceUID,\n  s.series_instance_uid as SeriesInstanceUID,\n  q.manufacturer as Mfr,\n  q.manufacturer_model_name as Model,\n  q.software_versions\nfrom\n  general_series s,\n  study t,\n  patient p,\n  trial_data_provenance tdp,\n  general_equipment q\nwhere\n  s.study_pk_id = t.study_pk_id and\n  s.general_equipment_pk_id = q.general_equipment_pk_id and\n  t.patient_pk_id = p.patient_pk_id and\n  p.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and\n  tdp.dp_site_name = ?\n	{collection,site}	{PID,Modality,StudyDate,StudyDescription,SeriesDescription,SeriesNumber,StudyInstanceUID,SeriesInstanceUID,Mfr,Model,software_versions}	{intake}	intake	List of all Series By Collection, Site on Intake\n
IntakeSeriesWithSignatureByCollectionSite	select\n  p.patient_id as PID,\n  s.modality as Modality,\n  t.study_date as StudyDate,\n  t.study_desc as StudyDescription,\n  s.series_desc as SeriesDescription,\n  s.series_number as SeriesNumber,\n  t.study_instance_uid as StudyInstanceUID,\n  s.series_instance_uid as series_instance_uid,\n  concat(q.manufacturer, ":", q.manufacturer_model_name, ":",\n  q.software_versions) as signature\nfrom\n  general_series s,\n  study t,\n  patient p,\n  trial_data_provenance tdp,\n  general_equipment q\nwhere\n  s.study_pk_id = t.study_pk_id and\n  s.general_equipment_pk_id = q.general_equipment_pk_id and\n  t.patient_pk_id = p.patient_pk_id and\n  p.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and\n  tdp.dp_site_name = ?\n	{collection,site}	{series_instance_uid,Modality,signature}	{intake}	intake	List of all Series By Collection, Site on Intake\n
LastFilesInSeries	select root_path || '/' || rel_path as path\nfrom file_location natural join file_storage_root\nwhere file_id in (\nselect file_id from \n  (\n  select \n    distinct sop_instance_uid, max(file_id) as file_id\n  from \n    file_series natural join ctp_file \n    natural join file_sop_common\n  where \n    series_instance_uid = ?\n    and visibility is null\n  group by sop_instance_uid\n) as foo);\n	{series_instance_uid}	{path}	{by_series}	posda_files	Last files uploaded by series\n
NewSopsReceivedBetweenDates	select\n   distinct project_name, site_name, patient_id,\n   study_instance_uid, series_instance_uid, count(*) as num_sops,\n   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\nfrom (\n  select \n    distinct project_name, site_name, patient_id,\n    study_instance_uid, series_instance_uid, sop_instance_uid,\n    count(*) as num_files, sum(num_uploads) as num_uploads,\n    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\n  from (\n    select\n      distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, count(*) as num_uploads, max(import_time) as last_loaded,\n         min(import_time) as first_loaded\n    from (\n      select\n        distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, import_time\n      from\n        ctp_file natural join file_patient natural join\n        file_study natural join file_series natural join\n        file_sop_common natural join file_import natural join\n        import_event\n      where\n        visibility is null and sop_instance_uid in (\n          select distinct sop_instance_uid\n          from \n            file_import natural join import_event natural join file_sop_common\n          where import_time > ? and import_time < ?\n        )\n      ) as foo\n    group by\n      project_name, site_name, patient_id, study_instance_uid, \n      series_instance_uid, sop_instance_uid, file_id\n  )as foo\n  group by \n    project_name, site_name, patient_id, study_instance_uid, \n    series_instance_uid, sop_instance_uid\n) as foo\nwhere num_uploads = 1\ngroup by \n  project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid\n	{start_time,end_time}	{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,first_loaded,last_loaded}	{receive_reports}	posda_files	Series received between dates with sops without duplicates\n
NewSopsReceivedBetweenDatesByCollection	select\n   distinct project_name, site_name, patient_id,\n   study_instance_uid, series_instance_uid, count(*) as num_sops,\n   min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\nfrom (\n  select \n    distinct project_name, site_name, patient_id,\n    study_instance_uid, series_instance_uid, sop_instance_uid,\n    count(*) as num_files, sum(num_uploads) as num_uploads,\n    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\n  from (\n    select\n      distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, count(*) as num_uploads, max(import_time) as last_loaded,\n         min(import_time) as first_loaded\n    from (\n      select\n        distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, import_time\n      from\n        ctp_file natural join file_patient natural join\n        file_study natural join file_series natural join\n        file_sop_common natural join file_import natural join\n        import_event\n      where\n        visibility is null and sop_instance_uid in (\n          select distinct sop_instance_uid\n          from \n            file_import natural join import_event natural join file_sop_common\n            natural join ctp_file\n          where import_time > ? and import_time < ? and\n            project_name = ? and visibility is null\n        )\n      ) as foo\n    group by\n      project_name, site_name, patient_id, study_instance_uid, \n      series_instance_uid, sop_instance_uid, file_id\n  )as foo\n  group by \n    project_name, site_name, patient_id, study_instance_uid, \n    series_instance_uid, sop_instance_uid\n) as foo\nwhere num_uploads = 1\ngroup by \n  project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid\n	{start_time,end_time,collection}	{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,first_loaded,last_loaded}	{receive_reports}	posda_files	Series received between dates with sops without duplicates\n
NumEquipSigsForPrivateTagSigs	select distinct element_signature, count(*) from (\nselect\n  distinct element_signature, equipment_signature\nfrom \n  equipment_signature natural join series_scan\n  natural join scan_element natural join element_signature\n  natural join scan_event\nwhere scan_event_id = ? and is_private) as foo\ngroup by element_signature\norder by element_signature\n	{scan_id}	{element_signature,count}	{tag_usage}	posda_phi	Number of Equipment signatures in which tags are featured\n
NumEquipSigsForTagSigs	select distinct element_signature, count(*) from (\nselect\n  distinct element_signature, equipment_signature\nfrom \n  equipment_signature natural join series_scan\n  natural join scan_element natural join element_signature\n  natural join scan_event\nwhere scan_event_id = ?) as foo\ngroup by element_signature\norder by element_signature\n	{scan_id}	{element_signature,count}	{tag_usage}	posda_phi	Number of Equipment signatures in which tags are featured\n
PatientStatusChangeByCollection	select\n  patient_id, old_pat_status as from,\n  new_pat_status as to, pat_stat_change_who as by,\n  pat_stat_change_why as why,\n  when_pat_stat_changed as when\nfrom patient_import_status_change\nwhere patient_id in(\n  select distinct patient_id\n  from file_patient natural join ctp_file\n  where project_name = ? and visibility is null\n)\norder by patient_id, when_pat_stat_changed\n	{collection}	{patient_id,from,to,by,why,when}	{PatientStatus}	posda_files	Get History of Patient Status Changes by Collection\n
PatientStatusChangeByPatient	select\n  patient_id, old_pat_status as from,\n  new_pat_status as to, pat_stat_change_who as by,\n  pat_stat_change_why as why,\n  when_pat_stat_changed as when\nfrom patient_import_status_change\nwhere patient_id = ?\norder by when\n	{patient_id}	{patient_id,from,to,by,why,when}	{PatientStatus}	posda_files	Get History of Patient Status Changes by Patient Id\n
PatientStatusCountsByCollection	select\n  distinct project_name as collection, patient_import_status as status,\n  count(distinct patient_id) as num_patients\nfrom\n  patient_import_status natural join file_patient natural join ctp_file\nwhere project_name = ? and visibility is null\ngroup by collection, status\n	{collection}	{collection,status,num_patients}	{FindSubjects,PatientStatus}	posda_files	Find All Subjects which have at least one visible file\n
FilesByScanValueLikeTag	select\n  distinct series_instance_uid,\n  series_scanned_file as file, \n  element_signature, value, sequence_level,\n  item_number\nfrom\n  scan_event natural join series_scan natural join seen_value\n  natural join element_signature natural join \n  scan_element natural left join sequence_index\nwhere\n  scan_event_id = ? and value like ? and element_signature = ?\norder by series_instance_uid, file\n	{scan_id,value,tag}	{series_instance_uid,file,element_signature,value,sequence_level,item_number}	{tag_usage,phi_review}	posda_phi	Find out where specific value, tag combinations occur in a scan\n
PixDupsByCollecton	select \n  distinct series_instance_uid, count(*)\nfrom \n  ctp_file natural join file_series \nwhere \n  project_name = ? and visibility is null\n  and file_id in (\n    select \n      distinct file_id\n    from\n      file_image natural join image natural join unique_pixel_data\n      natural join ctp_file\n    where digest in (\n      select\n        distinct pixel_digest\n      from (\n        select\n          distinct pixel_digest, count(*)\n        from (\n          select \n            distinct unique_pixel_data_id, pixel_digest, project_name,\n            site_name, patient_id, count(*) \n          from (\n            select\n              distinct unique_pixel_data_id, file_id, project_name,\n              site_name, patient_id, \n              unique_pixel_data.digest as pixel_digest \n            from\n              image natural join file_image natural join \n              ctp_file natural join file_patient fq\n              join unique_pixel_data using(unique_pixel_data_id)\n            where visibility is null\n          ) as foo \n          group by \n            unique_pixel_data_id, project_name, pixel_digest,\n            site_name, patient_id\n        ) as foo \n        group by pixel_digest\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) \ngroup by series_instance_uid\norder by count desc;\n	{collection}	{series_instance_uid,count}	{pix_data_dups}	posda_files	Counts of duplicate pixel data in series by Collection\n
PixelDataIdByFileId	select\n  distinct file_id, image_id, unique_pixel_data_id\nfrom\n  file_image natural join image\nwhere\n  file_id = ?\n	{file_id}	{file_id,image_id,unique_pixel_data_id}	{by_file_id,pixel_data_id,posda_files}	posda_files	Get unique_pixel_data_id for file_id \n
PixelDataIdByFileIdWithOtherFileId	select\n  distinct f.file_id as file_id, image_id, unique_pixel_data_id, \n  l.file_id as other_file_id\nfrom\n  file_image f natural join image natural join unique_pixel_data\n  join pixel_location l using(unique_pixel_data_id)\nwhere\n  f.file_id = ?\n	{file_id}	{file_id,image_id,unique_pixel_data_id,other_file_id}	{by_file_id,duplicates,pixel_data_id,posda_files}	posda_files	Get unique_pixel_data_id for file_id \n
PixelInfoByFileId	select\n  root_path || '/' || rel_path as file, file_offset, size, \n  bits_stored, bits_allocated, pixel_representation, number_of_frames,\n  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation\nfrom\n  file_image f natural join image natural join unique_pixel_data\n  join pixel_location pl using(unique_pixel_data_id), \n  file_location fl natural join file_storage_root\nwhere\n  f.file_id = ? and pl.file_id = fl.file_id\n  and f.file_id = pl.file_id\n	{image_id}	{file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation}	{}	posda_files	Get pixel descriptors for a particular image id\n
PixelInfoByImageId	select\n  root_path || '/' || rel_path as file, file_offset, size, \n  bits_stored, bits_allocated, pixel_representation, number_of_frames,\n  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation\nfrom\n  image natural join unique_pixel_data natural join pixel_location\n  natural join file_location natural join file_storage_root\nwhere image_id = ?\n	{image_id}	{file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation}	{}	posda_files	Get pixel descriptors for a particular image id\n
PixelInfoBySeries	select\n  f.file_id as file_id, root_path || '/' || rel_path as file,\n  file_offset, size, modality,\n  bits_stored, bits_allocated, pixel_representation, number_of_frames,\n  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation,\n  planar_configuration\nfrom\n  file_image f natural join image natural join unique_pixel_data\n  natural join file_series\n  join pixel_location pl using(unique_pixel_data_id), \n  file_location fl natural join file_storage_root\nwhere\n  pl.file_id = fl.file_id\n  and f.file_id = pl.file_id\n  and f.file_id in (\n  select distinct file_id\n  from file_series natural join ctp_file\n  where series_instance_uid = ? and visibility is null\n)\n	{series_instance_uid}	{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,planar_configuration,modality}	{}	posda_files	Get pixel descriptors for all files in a series\n
RecordPatientStatusChange	insert into patient_import_status_change(\n  patient_id, when_pat_stat_changed,\n  pat_stat_change_who, pat_stat_change_why,\n  old_pat_status, new_pat_status\n) values (\n  ?, now(),\n  ?, ?,\n  ?, ?\n)\n	{patient_id,who,why,old_status,new_status}	\N	{NotInteractive,PatientStatus,Update}	posda_files	Record a change to Patient Import Status\nFor use in scripts\nNot really intended for interactive use\n
PixelInfoBySopInstance	select\n  f.file_id, root_path || '/' || rel_path as file, file_offset, size, \n  bits_stored, bits_allocated, pixel_representation, number_of_frames,\n  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation,\n  planar_configuration, modality\nfrom\n  file_image f natural join image natural join unique_pixel_data\n  join pixel_location pl using(unique_pixel_data_id), \n  file_location fl natural join file_storage_root\n  natural join file_series \nwhere\n  pl.file_id = fl.file_id\n  and f.file_id = pl.file_id\n  and f.file_id in (\n    select distinct file_id\n    from file_sop_common where sop_instance_uid = ?\n  )\n	{sop_instance_uid}	{file_id,file,file_offset,size,bits_stored,bits_allocated,pixel_representation,number_of_frames,samples_per_pixel,pixel_rows,pixel_columns,photometric_interpretation,planar_configuration,modality}	{}	posda_files	Get pixel descriptors for a particular image id\n
PixelTypesWithGeo	select\n  distinct photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  pixel_representation,\n  planar_configuration,\n  iop\nfrom\n  image natural join image_geometry\norder by photometric_interpretation\n	{}	{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,planar_configuration,iop}	{find_pixel_types,image_geometry,posda_files}	posda_files	Get distinct pixel types with geometry\n
PixelTypesWithNoGeo	select\n  distinct photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  pixel_representation,\n  planar_configuration\nfrom\n  image i where image_id not in (\n    select image_id from image_geometry g where g.image_id = i.image_id\n  )\norder by photometric_interpretation\n	{}	{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,planar_configuration}	{find_pixel_types,image_geometry,posda_files}	posda_files	Get pixel types with no geometry\n
PixelTypesWithSlopeCT	select\n  distinct photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  pixel_representation,\n  planar_configuration,\n  modality,\n  slope,\n  intercept,\n  count(*)\nfrom\n  image natural join file_image natural join file_series\n  natural join file_slope_intercept natural join slope_intercept\nwhere\n  modality = 'CT'\ngroup by\n  photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  pixel_representation,\n  planar_configuration,\n  modality,\n  slope,\n  intercept\norder by\n  photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  pixel_representation,\n  planar_configuration,\n  modality,\n  slope,\n  intercept\n	{}	{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,planar_configuration,modality,slope,intercept,count}	{}	posda_files	Get distinct pixel types\n
PosdaImagesByCollectionSite	select distinct\n  patient_id as "PID",\n  modality as "Modality",\n  sop_instance_uid as "SopInstance",\n  study_date as "StudyDate",\n  study_description as "StudyDescription",\n  series_description as "SeriesDescription",\n  study_instance_uid as "StudyInstanceUID",\n  series_instance_uid as "SeriesInstanceUID",\n  manufacturer as "Mfr",\n  manuf_model_name as "Model",\n  software_versions\nfrom\n  file_patient natural join file_series natural join\n  file_sop_common natural join file_study natural join\n  file_equipment natural join ctp_file\nwhere\n  file_id in (\n  select distinct file_id from ctp_file\n  where project_name = ? and site_name = ? and visibility is null)\n	{collection,site}	{PID,Modality,SopInstance,StudyDate,StudyDescription,SeriesDescription,StudyInstanceUID,SeriesInstanceUID,Mfr,Model,software_versions}	{posda_files}	posda_files	List of all Files Images By Collection, Site\n
PosdaTotals	select \n    distinct project_name, site_name, count(*) as num_subjects,\n    sum(num_studies) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files,\n    sum(total_sops) as total_sops\nfrom (\n  select\n    distinct project_name, site_name, patient_id,\n    count(*) as num_studies, sum(num_series) as num_series, \n    sum(total_files) as total_files,\n    sum(total_sops) as total_sops\n  from (\n    select\n       distinct project_name, site_name, patient_id, \n       study_instance_uid, count(*) as num_series,\n       sum(num_sops) as total_sops,\n       sum(num_files) as total_files\n    from (\n      select\n        distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid,\n        count(distinct file_id) as num_files,\n        count(distinct sop_instance_uid) as num_sops\n      from (\n        select\n          distinct project_name, site_name, patient_id,\n          study_instance_uid, series_instance_uid, sop_instance_uid,\n          file_id\n        from\n           ctp_file natural join file_study natural join\n           file_series natural join file_sop_common\n           natural join file_patient\n        where\n          visibility is null\n      ) as foo\n      group by\n        project_name, site_name, patient_id, \n        study_instance_uid, series_instance_uid\n    ) as foo\n    group by project_name, site_name, patient_id, study_instance_uid\n  ) as foo\n  group by project_name, site_name, patient_id\n) as foo\ngroup by project_name, site_name\norder by project_name, site_name\n	{}	{project_name,site_name,num_subjects,num_studies,num_series,total_files,total_sops}	{}	posda_files	Produce total counts for all collections currently in Posda\n
SendEventSummary	select\n  reason_for_send, num_events, files_sent, earliest_send,\n  finished, finished - earliest_send as duration\nfrom (\n  select\n    distinct reason_for_send, count(*) as num_events, sum(number_of_files) as files_sent,\n    min(send_started) as earliest_send, max(send_ended) as finished\n  from dicom_send_event\n  group by reason_for_send\n  order by earliest_send\n) as foo\n	{}	{reason_for_send,num_events,files_sent,earliest_send,finished,duration}	{send_to_intake}	posda_files	Summary of SendEvents by Reason\n
CreateScanElement	insert into scan_element(\n  element_signature_id, seen_value_id, series_scan_id\n)values(\n  ?, ?, ?)\n	{element_signature_id,seen_value_id,series_scan_id}	{}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Create Scan Element
PosdaTotalsHidden	select \n    distinct project_name, site_name, count(*) as num_subjects,\n    sum(num_studies) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files,\n    sum(total_sops) as total_sops\nfrom (\n  select\n    distinct project_name, site_name, patient_id,\n    count(*) as num_studies, sum(num_series) as num_series, \n    sum(total_files) as total_files,\n    sum(total_sops) as total_sops\n  from (\n    select\n       distinct project_name, site_name, patient_id, \n       study_instance_uid, count(*) as num_series,\n       sum(num_sops) as total_sops,\n       sum(num_files) as total_files\n    from (\n      select\n        distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid,\n        count(distinct file_id) as num_files,\n        count(distinct sop_instance_uid) as num_sops\n      from (\n        select\n          distinct project_name, site_name, patient_id,\n          study_instance_uid, series_instance_uid, sop_instance_uid,\n          file_id\n        from\n           ctp_file natural join file_study natural join\n           file_series natural join file_sop_common\n           natural join file_patient\n        where\n          visibility = 'hidden'\n      ) as foo\n      group by\n        project_name, site_name, patient_id, \n        study_instance_uid, series_instance_uid\n    ) as foo\n    group by project_name, site_name, patient_id, study_instance_uid\n  ) as foo\n  group by project_name, site_name, patient_id\n) as foo\ngroup by project_name, site_name\norder by project_name, site_name\n	{}	{project_name,site_name,num_subjects,num_studies,num_series,total_files,total_sops}	{}	posda_files	Get totals of files hidden in Posda\n
PosdaTotalsWithDateRange	select \n    distinct project_name, site_name, count(*) as num_subjects,\n    sum(num_studies) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\nfrom (\n  select\n    distinct project_name, site_name, patient_id, count(*) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\n  from (\n    select\n       distinct project_name, site_name, patient_id, study_instance_uid, \n       count(*) as num_series, sum(num_files) as total_files\n    from (\n      select\n        distinct project_name, site_name, patient_id, study_instance_uid, \n        series_instance_uid, count(*) as num_files \n      from (\n        select\n          distinct project_name, site_name, patient_id, study_instance_uid,\n          series_instance_uid, sop_instance_uid \n        from\n           ctp_file natural join file_study natural join\n           file_series natural join file_sop_common natural join file_patient\n           natural join file_import natural join import_event\n        where\n          visibility is null and import_time >= ? and\n          import_time < ? \n      ) as foo\n      group by\n        project_name, site_name, patient_id, \n        study_instance_uid, series_instance_uid\n    ) as foo\n    group by project_name, site_name, patient_id, study_instance_uid\n  ) as foo\n  group by project_name, site_name, patient_id\n) as foo\ngroup by project_name, site_name\norder by project_name, site_name\n	{start_time,end_time}	{project_name,site_name,num_subjects,num_studies,num_series,total_files}	{}	posda_files	Get posda totals by date range\n
PosdaTotalsWithDateRangeWithHidden	select \n    distinct project_name, site_name, count(*) as num_subjects,\n    sum(num_studies) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\nfrom (\n  select\n    distinct project_name, site_name, patient_id, count(*) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\n  from (\n    select\n       distinct project_name, site_name, patient_id, study_instance_uid, \n       count(*) as num_series, sum(num_files) as total_files\n    from (\n      select\n        distinct project_name, site_name, patient_id, study_instance_uid, \n        series_instance_uid, count(*) as num_files \n      from (\n        select\n          distinct project_name, site_name, patient_id, study_instance_uid,\n          series_instance_uid, sop_instance_uid \n        from\n           ctp_file natural join file_study natural join\n           file_series natural join file_sop_common natural join file_patient\n           natural join file_import natural join import_event\n        where\n          import_time >= ? and\n          import_time < ? \n      ) as foo\n      group by\n        project_name, site_name, patient_id, \n        study_instance_uid, series_instance_uid\n    ) as foo\n    group by project_name, site_name, patient_id, study_instance_uid\n  ) as foo\n  group by project_name, site_name, patient_id\n) as foo\ngroup by project_name, site_name\norder by project_name, site_name\n	{start_time,end_time}	{project_name,site_name,num_subjects,num_studies,num_series,total_files}	{}	posda_files	Get posda totals by date range\n
PosdaTotalsWithHidden	select \n    distinct project_name, site_name, count(*) as num_subjects,\n    sum(num_studies) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\nfrom (\n  select\n    distinct project_name, site_name, patient_id, count(*) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\n  from (\n    select\n       distinct project_name, site_name, patient_id, study_instance_uid, \n       count(*) as num_series, sum(num_files) as total_files\n    from (\n      select\n        distinct project_name, site_name, patient_id, study_instance_uid, \n        series_instance_uid, count(*) as num_files \n      from (\n        select\n          distinct project_name, site_name, patient_id, study_instance_uid,\n          series_instance_uid, sop_instance_uid \n        from\n           ctp_file natural join file_study natural join\n           file_series natural join file_sop_common natural join file_patient\n       ) as foo\n       group by\n         project_name, site_name, patient_id, \n         study_instance_uid, series_instance_uid\n    ) as foo\n    group by project_name, site_name, patient_id, study_instance_uid\n  ) as foo\n  group by project_name, site_name, patient_id\n  order by project_name, site_name, patient_id\n) as foo\ngroup by project_name, site_name\norder by project_name, site_name\n	{}	{project_name,site_name,num_subjects,num_studies,num_series,total_files}	{}	posda_files	Get total posda files including hidden\n
PrivateTagUsage	select\n  distinct element_signature, equipment_signature\nfrom \n  equipment_signature natural join series_scan\n  natural join scan_element natural join element_signature\n  natural join scan_event\nwhere scan_event_id = ? and is_private\norder by element_signature;\n	{scan_id}	{element_signature,equipment_signature}	{tag_usage}	posda_phi	Which equipment signatures for which private tags\n
PrivateTagsByEquipment	select distinct element_signature from (\nselect\n  distinct element_signature, equipment_signature\nfrom \n  equipment_signature natural join series_scan\n  natural join scan_element natural join element_signature\n  natural join scan_event\nwhere scan_event_id = ? and is_private ) as foo\nwhere equipment_signature = ?\norder by element_signature;\n	{scan_id,equipment_signature}	{element_signature}	{tag_usage}	posda_phi	Which equipment signatures for which private tags\n
SendEventsByReason	select\n  send_started, send_ended - send_started as duration,\n  destination_host, destination_port,\n  number_of_files as to_send, files_sent,\n  invoking_user, reason_for_send\nfrom (\n  select\n    distinct dicom_send_event_id,\n    count(distinct file_path) as files_sent\n  from\n    dicom_send_event natural join dicom_file_send\n  where\n    reason_for_send = ?\n  group by dicom_send_event_id\n) as foo\nnatural join dicom_send_event\norder by send_started\n	{reason}	{send_started,duration,destination_host,destination_port,to_send,files_sent,invoking_user,reason_for_send}	{send_to_intake}	posda_files	List of Send Events By Reason\n
SentToIntakeByDate	select\n  send_started, send_ended - send_started as duration,\n  destination_host, destination_port,\n  number_of_files as to_send, files_sent,\n  invoking_user, reason_for_send\nfrom (\n  select\n    distinct dicom_send_event_id,\n    count(distinct file_path) as files_sent\n  from\n    dicom_send_event natural join dicom_file_send\n  where\n    send_started > ? and send_started < ?\n  group by dicom_send_event_id\n) as foo\nnatural join dicom_send_event\norder by send_started\n	{from_date,to_date}	{send_started,duration,destination_host,destination_port,to_send,files_sent,invoking_user,reason_for_send}	{send_to_intake}	posda_files	List of Files Sent To Intake By Date\n
SeriesByLikeDescriptionAndCollection	select distinct\n  series_instance_uid, series_description\nfrom\n  file_series natural join ctp_file\nwhere project_name = ? and series_description like ?\n	{collection,pattern}	{series_instance_uid,series_description}	{find_series}	posda_files	Get a list of Series by Collection matching Series Description\n
SeriesCollectionSite	select distinct\n  series_instance_uid\nfrom\n  file_series natural join ctp_file\nwhere project_name = ? and site_name = ? and visibility is null\n	{collection,site}	{series_instance_uid}	{find_series}	posda_files	Get a list of Series by Collection, Site\n
SeriesEquipmentByValueSignature	select\n  distinct series_instance_uid, element_signature, value, vr,\n  equipment_signature\nfrom\n  scan_event natural join series_scan\n  natural join scan_element natural join element_signature\n  natural join equipment_signature\n  natural join seen_value\nwhere\n  scan_event_id = ? and\n  value = ? and\n  element_signature = ?\norder by value, element_signature, vr\n	{scan_id,value,tag_signature}	{series_instance_uid,value,vr,element_signature,equipment_signature}	{tag_usage}	posda_phi	List of series, values, vr seen in scan with equipment signature\n
SeriesLike	select\n   distinct collection, site, pat_id,\n   series_instance_uid, series_description, count(*)\nfrom (\n  select\n   distinct\n     project_name as collection, site_name as site,\n     file_id, series_instance_uid, patient_id as pat_id,\n     series_description\n  from\n     ctp_file natural join file_series natural join file_patient\n  where\n     project_name = ? and site_name = ? and \n     series_description like ?\n) as foo\ngroup by collection, site, pat_id, series_instance_uid, series_description\norder by collection, site, pat_id\n	{collection,site,description_matching}	{collection,site,pat_id,series_instance_uid,series_description,count}	{find_series,pattern,posda_files}	posda_files	Select series not matching pattern\n
SeriesNickname	select\n  project_name, site_name, subj_id, series_nickname\nfrom\n  series_nickname\nwhere\n  series_instance_uid = ?\n	{series_instance_uid}	{project_name,site_name,subj_id,series_nickname}	{}	posda_nicknames	Get a nickname, etc for a particular series uid\n
SeriesNotLikeWithModality	select\n   distinct series_instance_uid, series_description, count(*)\nfrom (\n  select\n   distinct\n     file_id, series_instance_uid, series_description\n  from\n     ctp_file natural join file_series\n  where\n     modality = ? and project_name = ? and site_name = ? and \n     series_description not like ? and visibility is null\n) as foo\ngroup by series_instance_uid, series_description\n	{modality,collection,site,description_not_matching}	{series_instance_uid,series_description,count}	{find_series,pattern,posda_files}	posda_files	Select series not matching pattern by modality\n
SeriesSentToIntakeByDate	select\n  series_to_send as series_instance_uid,\n  send_started, send_ended - send_started as duration,\n  destination_host, destination_port,\n  number_of_files as to_send, files_sent,\n  invoking_user, reason_for_send\nfrom (\n  select\n    distinct dicom_send_event_id,\n    count(distinct file_path) as files_sent\n  from\n    dicom_send_event natural join dicom_file_send\n  where\n    send_started > ? and send_started < ?\n  group by dicom_send_event_id\n) as foo\nnatural join dicom_send_event\norder by send_started\n	{from_date,to_date}	{send_started,duration,series_instance_uid,destination_host,destination_port,to_send,files_sent,invoking_user,reason_for_send}	{send_to_intake}	posda_files	List of Series Sent To Intake By Date\n
UpdatePatientImportStatus	update patient_import_status set \n  patient_import_status = ?\nwhere patient_id = ?\n	{patient_id,status}	\N	{NotInteractive,PatientStatus,Update}	posda_files	Update Patient Status\nFor use in scripts\nNot really intended for interactive use\n
SeriesWithRGB	select\n  distinct series_instance_uid\nfrom\n  image natural join file_image\n  natural join file_series\n  natural join ctp_file\nwhere\n  photometric_interpretation = 'RGB'\n  and visibility is null\n	{}	{series_instance_uid}	{find_series,posda_files,rgb}	posda_files	Get distinct pixel types with geometry and rgb\n
SopNickname	select\n  project_name, site_name, subj_id, sop_nickname, modality,\n  has_modality_conflict\nfrom\n  sop_nickname\nwhere\n  sop_instance_uid = ?\n	{sop_instance_uid}	{project_name,site_name,subj_id,sop_nickname,modality,has_modality_conflict}	{}	posda_nicknames	Get a nickname, etc for a particular SOP Instance  uid\n
StudyNickname	select\n  project_name, site_name, subj_id, study_nickname\nfrom\n  study_nickname\nwhere\n  study_instance_uid = ?\n	{study_instance_uid}	{project_name,site_name,subj_id,study_nickname}	{}	posda_nicknames	Get a nickname, etc for a particular study uid\n
SubjectCountByCollectionSite	select\n  distinct\n    patient_id, count(distinct file_id)\nfrom\n  ctp_file natural join file_patient\nwhere\n  project_name = ? and site_name = ? and visibility is null\ngroup by\n  patient_id \norder by\n  patient_id\n	{collection,site}	{patient_id,count}	{counts}	posda_files	Counts query by Collection, Site\n
DistinctFilesByScanTag	select\n  distinct series_instance_uid,\n  series_scanned_file as file, \n  element_signature\nfrom\n  scan_event natural join series_scan natural join seen_value\n  natural join element_signature natural join \n  scan_element natural left join sequence_index\nwhere\n  scan_event_id = ? and element_signature = ?\norder by series_instance_uid, file\n	{scan_id,tag}	{series_instance_uid,file,element_signature,value,sequence_level,item_number}	{tag_usage,phi_review}	posda_phi	Find out where specific value, tag combinations occur in a scan\n
SubjectsWithModalityByCollectionSite	select\n  distinct patient_id, count(*) as num_files\nfrom\n  ctp_file natural join file_patient natural join file_series\nwhere\n  modality = ? and project_name = ? and site_name = ?\ngroup by patient_id\norder by patient_id\n	{modality,project_name,site_name}	{patient_id,num_files}	{FindSubjects}	posda_files	Find All Subjects with given modality in Collection, Site\n
SubjectsWithModalityByCollectionSiteIntake	select\n  distinct i.patient_id, modality, count(*) as num_files\nfrom\n  general_image i, trial_data_provenance tdp, general_series s\nwhere\n  s.general_series_pk_id = i.general_series_pk_id and \n  i.trial_dp_pk_id = tdp.trial_dp_pk_id and \n  modality = ? and\n  tdp.project = ? and \n  tdp.dp_site_name = ?\ngroup by patient_id, modality\n	{modality,project_name,site_name}	{patient_id,modality,num_files}	{FindSubjects,SymLink,intake}	intake	Find All Subjects with given modality in Collection, Site\n
TagUsage	select\n  distinct element_signature, equipment_signature\nfrom \n  equipment_signature natural join series_scan\n  natural join scan_element natural join element_signature\n  natural join scan_event\nwhere scan_event_id = ?\norder by element_signature;\n	{scan_id}	{element_signature,equipment_signature}	{tag_usage}	posda_phi	Which equipment signatures for which tags\n
GetScanElementId	select currval('scan_element_scan_element_id_seq') as id	{}	{id}	{NotInteractive,UsedInPhiSeriesScan}	posda_phi	Get current value of ScanElementId Sequence\n
StudyConsistency	select distinct\n  study_instance_uid, study_date, study_time,\n  referring_phy_name, study_id, accession_number,\n  study_description, phys_of_record, phys_reading,\n  admitting_diag, count(*)\nfrom\n  file_study natural join ctp_file\nwhere study_instance_uid = ? and visibility is null\ngroup by\n  study_instance_uid, study_date, study_time,\n  referring_phy_name, study_id, accession_number,\n  study_description, phys_of_record, phys_reading,\n  admitting_diag\n	{study_instance_uid}	{study_instance_uid,count,study_description,study_date,study_time,referring_phy_name,study_id,accession_number,phys_of_record,phys_reading,admitting_diag}	{by_study,consistency,study_consistency}	posda_files	Check a Study for Consistency\n
CreateSimpleElementValueOccurance	insert into element_value_occurance(\nelement_seen_id, value_seen_id, series_scan_instance_id, phi_scan_instance_id\n)values(?, ?, ?, ?)	{element_seen_id,value_seen_id,series_scan_instance_id,scan_instance_id}	{}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Create a new scanned value instance
IncrementSimpleSeriesScanned	update phi_scan_instance set\n  num_series_scanned = num_series_scanned + 1\nwhere\n  phi_scan_instance_id = ?	{id}	{}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Increment series scanned
TestThisOne	select\n  patient_id, patient_import_status,\n  count(distinct file_id) as total_files,\n  min(import_time) min_time, max(import_time) as max_time,\n  count(distinct study_instance_uid) as num_studies,\n  count(distinct series_instance_uid) as num_series\nfrom\n  ctp_file natural join file natural join\n  file_import natural join import_event natural join\n  file_study natural join file_series natural join file_patient\n  natural join patient_import_status\nwhere\n  project_name = ? and site_name = ? and visibility is null\ngroup by patient_id, patient_import_status\n	{project_name,site_name,PatientStatus}	{patient_id,patient_import_status,total_files,min_time,max_time,num_studies,num_series}	{}	posda_files	
TotalDiskSpace	select\n  sum(size) as total_bytes\nfrom\n  file\nwhere\n  file_id in (\n  select distinct file_id\n  from ctp_file\n  )\n	{}	{total_bytes}	{all,posda_files,storage_used}	posda_files	Get total disk space used\n
ValuesWithVrTagAndCountLimited	select distinct vr, value, element_signature, num_files from (\n  select\n    distinct vr, value, element_signature, count(*)  as num_files\n  from\n    scan_event natural join series_scan natural join seen_value\n    natural join element_signature natural join scan_element\n  where\n    scan_event_id = ? and\n    vr not in (\n      'AE', 'AT', 'DS', 'FL', 'FD', 'IS', 'OD', 'OF', 'OL', 'OW',\n      'SL', 'SQ', 'SS', 'TM', 'UL', 'US'\n    )\n  group by value, element_signature, vr\n) as foo\norder by vr, value\n	{scan_id}	{vr,value,element_signature,num_files}	{tag_usage}	posda_phi	List of values seen in scan by VR (with count of elements)\n
VrsSeen	select distinct vr, count(*) from (\n  select\n    distinct value, element_signature, vr\n  from\n    scan_event natural join series_scan natural join seen_value\n    natural join element_signature natural join scan_element\n  where\n    scan_event_id = ?\n) as foo\ngroup by vr\norder by vr\n	{scan_id}	{vr,count}	{tag_usage}	posda_phi	List of VR's seen in scan (with count)\n
TotalsLike	select \n    distinct project_name, site_name, count(*) as num_subjects,\n    sum(num_studies) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\nfrom (\n  select\n    distinct project_name, site_name, patient_id, count(*) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\n  from (\n    select\n       distinct project_name, site_name, patient_id, study_instance_uid, \n       count(*) as num_series, sum(num_files) as total_files\n    from (\n      select\n        distinct project_name, site_name, patient_id, study_instance_uid, \n        series_instance_uid, count(*) as num_files \n      from (\n        select\n          distinct project_name, site_name, patient_id, study_instance_uid,\n          series_instance_uid, sop_instance_uid \n        from\n           ctp_file natural join file_study natural join\n           file_series natural join file_sop_common natural join file_patient\n         where\n           project_name like ? and visibility is null\n       ) as foo\n       group by\n         project_name, site_name, patient_id, \n         study_instance_uid, series_instance_uid\n    ) as foo\n    group by project_name, site_name, patient_id, study_instance_uid\n  ) as foo\n  group by project_name, site_name, patient_id\n  order by project_name, site_name, patient_id\n) as foo\ngroup by project_name, site_name\norder by project_name, site_name\n	{pattern}	{project_name,site_name,num_subjects,num_studies,num_series,total_files}	{}	posda_files	Get Posda totals for with collection matching pattern\n
UnHideFilesCSP	update ctp_file set visibility = null where file_id in (\n  select\n    distinct file_id\n  from\n    ctp_file natural join file_patient\n  where\n    project_name = ? and site_name = ?\n    and visibility = 'hidden' and patient_id = ?\n);\n	{collection,site,subject}	\N	{}	posda_files	UnHide all files hidden by Collection, Site, Subject\n
FinalizeSimpleScanInstance	update phi_scan_instance set\n  end_time = now()\nwhere\n  phi_scan_instance_id = ?	{id}	{}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Finalize PHI Scan
PhiSimpleScanStatus	select\n  phi_scan_instance_id as id,\n  start_time,\n  end_time,\n  end_time - start_time as duration,\n  description,\n  num_series as to_scan,\n  num_series_scanned as scanned\nfrom \n  phi_scan_instance\norder by id\n	{}	{id,start_time,end_time,duration,description,to_scan,scanned}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
ValuesByVr	select distinct value, count(*) from (\n  select\n    distinct value, element_signature, vr\n  from\n    scan_event natural join series_scan natural join seen_value\n    natural join element_signature natural join scan_element\n  where\n    scan_event_id = ? and vr = ?\n) as foo\ngroup by value\norder by value\n	{scan_id,vr}	{value,count}	{tag_usage}	posda_phi	List of values seen in scan by VR (with count of elements)\n
WhereSeriesSits	select distinct\n  project_name as collection,\n  site_name as site,\n  patient_id,\n  study_instance_uid,\n  series_instance_uid,\n  count(distinct file_id) as num_files\nfrom\n  file_patient natural join\n  file_study natural join\n  file_series natural join\n  ctp_file\nwhere file_id in (\n  select\n    distinct file_id\n  from\n    file_series natural join ctp_file\n  where\n    series_instance_uid = ? and visibility is null\n)\ngroup by\n  project_name, site_name, patient_id,\n  study_instance_uid, series_instance_uid\norder by\n  project_name, site_name, patient_id,\n  study_instance_uid, series_instance_uid\n	{series_instance_uid}	{collection,site,patient_id,study_instance_uid,series_instance_uid,num_files}	{by_series_instance_uid,posda_files,sops}	posda_files	Get Collection, Site, Patient, Study Hierarchy in which series resides\n
SeriesSendEventsByReason	select\n  series_to_send as series_instance_uid,\n  send_started, send_ended - send_started as duration,\n  destination_host, destination_port,\n  number_of_files as to_send, files_sent,\n  invoking_user, reason_for_send\nfrom (\n  select\n    distinct dicom_send_event_id,\n    count(distinct file_path) as files_sent\n  from\n    dicom_send_event natural join dicom_file_send\n  where\n    reason_for_send = ?\n  group by dicom_send_event_id\n) as foo\nnatural join dicom_send_event\norder by send_started\n	{reason}	{series_instance_uid,send_started,duration,destination_host,destination_port,to_send,files_sent,invoking_user,reason_for_send}	{send_to_intake}	posda_files	List of Send Events By Reason\n
GetScanEventById	select * from scan_event where scan_event_id = ?\n	{scan_id}	{scan_event_id,scan_started,scan_ended,scan_status,scan_description,num_series_to_scan,num_series_scanned}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	List of values seen in scan by VR (with count of elements)\n
FilesByModalityByCollectionSiteIntake	select\n  distinct i.patient_id, modality, s.series_instance_uid, sop_instance_uid, dicom_file_uri\nfrom\n  general_image i, trial_data_provenance tdp, general_series s\nwhere\n  s.general_series_pk_id = i.general_series_pk_id and \n  i.trial_dp_pk_id = tdp.trial_dp_pk_id and \n  modality = ? and\n  tdp.project = ? and \n  tdp.dp_site_name = ?	{modality,project_name,site_name}	{patient_id,modality,series_instance_uid,sop_instance_uid,dicom_file_uri}	{FindSubjects,intake,FindFiles}	intake	Find All Files with given modality in Collection, Site on Intake\n
DiskSpaceByCollectionSiteSummary	select\n  distinct project_name as collection, site_name as site, sum(size) as total_bytes\nfrom\n  ctp_file natural join file\nwhere\n  file_id in (\n  select distinct file_id\n  from ctp_file\n  )\ngroup by project_name, site_name\norder by total_bytes\n	{}	{collection,site,total_bytes}	{by_collection,posda_files,storage_used,summary}	posda_files	Get disk space used for all collections, sites\n
GetElementSignatureId	select currval('element_signature_element_signature_id_seq') as id	{}	{id}	{NotInteractive,UsedInPhiSeriesScan,ElementDisposition}	posda_phi	Get current value of ElementSignatureId Sequence\n
GetScanEventId	select currval('series_scan_series_scan_id_seq') as id	{}	{}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	List of values seen in scan by VR (with count of elements)\n
GetEquipmentSignature	select * from equipment_signature where equipment_signature = ?\n	{equipment_signature}	{equipment_signature_id,equipment_signature}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Get Equipment Signature Id
CreateEquipmentSignature	insert into equipment_signature(equipment_signature)values(?)\n	{equipment_signature}	{}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Create New Equipment Signature Id
CreateSeenValue	insert into seen_value(value)values(?)	{value}	{}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Create New Seen Value
GetEquipmentSignatureId	select currval('equipment_signature_equipment_signature_id_seq') as id	{}	{id}	{NotInteractive,UsedInPhiSeriesScan}	posda_phi	Get current value of EquipmentSignatureId Sequence\n
GetSeenValue	select * from seen_value where value = ?\n	{value}	{seen_value_id,value}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Get Seen Value Id
GetSeenValueId	select currval('seen_value_seen_value_id_seq') as id	{}	{id}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Get current value of seen_value_id sequence
CreateElementSignature	insert into element_signature(element_signature, vr, is_private) values(?, ?, ?)\n	{element_signature,vr,is_private}	{}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Create New Element Signature Id
GetElementSignature	select * from element_signature\n  where element_signature = ? and vr = ?\n	{element_signature,vr}	{element_signature_id,element_signature,is_private,vr}	{UsedInPhiSeriesScan,NotInteractive,ElementDisposition}	posda_phi	Get Element Signature By Signature (pattern) and VR
CreateTableSequenceIndex	insert into sequence_index(\n  scan_element_id, sequence_level, item_number\n) values (?, ?, ?)\n	{scan_element_id,sequence_level,item_number}	{}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Create Table Sequence Id
UpdateSeriesScan	update series_scan\n  set series_scan_status = ?\nwhere series_scan_id = ?	{series_scan_status,series_scan_id}	{}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Update Series Scan to set status\n
InsertIntoSeriesScan	insert into series_scan(\n  scan_event_id, equipment_signature_id, series_instance_uid,\n  series_scan_status, series_scanned_file\n) values (\n  ?, ?, ?, 'In Process', ?)	{scan_id,equipment_signature_id,series_instance_uid,series_scanned_file}	{}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	List of values seen in scan by VR (with count of elements)\n
CreateScanEvent	insert into scan_event(\n  scan_started, scan_status, scan_description,\n  num_series_to_scan, num_series_scanned\n) values (\n  now(), 'In Process', ?,\n  ?, 0\n)\n\n	{description,num_series_to_scan}	{}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Create Scan Element
GetScanEventEventId	select currval('scan_event_scan_event_id_seq') as id\n	{}	{num_series_scanned,id}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Get current value of scan_event_id
UpdateSeriesScanned	update scan_event\nset num_series_scanned = ?\nwhere scan_event_id = ?	{num_series_scanned,scan_event_id}	{}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Update Series Scanned in scan event\n
GetSeriesWithSignatureIntake	select\n  distinct  s.series_instance_uid,\n  concat(\n    COALESCE(e.manufacturer, ''), \n    '_',\n    COALESCE(e.manufacturer_model_name, ''),\n     '_',\n    COALESCE(e.software_versions, '') \n  ) as signature\nfrom\n  general_series s, general_equipment e\nwhere\n  s.general_equipment_pk_id = e.general_equipment_pk_id and\n  s.general_series_pk_id in (\n    select\n      distinct i.general_series_pk_id\n    from\n      general_image i, trial_data_provenance tdp\n    where\n      i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n      tdp.project = ? and tdp.dp_site_name = ?\n  )	{collection,site}	{series_instance_uid,signature}	{signature}	intake	Get a list of Series with Signatures by Collection Intake\n
FirstFileInSeriesPosda	select root_path || '/' || rel_path as path\nfrom file_location natural join file_storage_root\nwhere file_id in (\nselect file_id from \n  (\n  select \n    distinct sop_instance_uid, min(file_id) as file_id\n  from \n    file_series natural join ctp_file \n    natural join file_sop_common\n  where \n    series_instance_uid = ?\n    and visibility is null\n  group by sop_instance_uid\n) as foo)\nlimit 1\n	{series_instance_uid}	{path}	{by_series,UsedInPhiSeriesScan}	posda_files	First files in series in Posda\n
UpdateSeriesFinished	update scan_event \nset scan_status = 'finished',\n  scan_ended = now()\nwhere scan_event_id = ?	{scan_event_id}	{}	{UsedInPhiSeriesScan,NotInteractive}	posda_phi	Update status to finished in scan event\n
UpdateElementDisposition	update element_signature set \n  private_disposition = ?,\n  name_chain = ?\nwhere\n  element_signature = ? and\n  vr = ?\n	{private_disposition,name_chain,element_signature,vr}	{}	{NotInteractive,Update,ElementDisposition}	posda_phi	Update Element Disposition\nFor use in scripts\nNot really intended for interactive use\n
PrivateTagCountReport	select \n  distinct element_signature, vr, count(*) as times_seen,\n  count(distinct value) as num_distinct_values \nfrom\n  element_signature natural join scan_element natural join seen_value\nwhere\n  is_private\ngroup by element_signature, vr\norder by element_signature, vr, times_seen, num_distinct_values;\n	{}	{element_signature,vr,times_seen,num_distinct_values}	{postgres_status,PrivateTagKb}	posda_phi	Get List of all Private Tags ever scanned with occurance and distinct value counts
PrivateTagCountValueList	select \n  distinct element_signature, vr, value, private_disposition as disposition, count(*) as num_files\nfrom\n  element_signature natural join scan_element natural join seen_value\nwhere\n  is_private\ngroup by element_signature, vr, value, private_disposition\norder by element_signature, vr, value	{}	{vr,value,element_signature,num_files,disposition}	{postgres_status,PrivateTagKb,NotInteractive}	posda_phi	Get List of Private Tags with All Values\n
RecordElementDispositionChange	insert into element_signature_change(\n  element_signature_id, when_sig_changed,\n  who_changed_sig, why_sig_changed,\n  old_disposition, new_disposition,\n  old_name_chain, new_name_chain\n) values (\n  ?, now(),\n  ?, ?,\n  ?, ?,\n  ?, ?\n)\n	{element_signature_id,who_changed_sig,why_sig_changed,old_disposition,new_disposition,old_name_chain,new_name_chain}	{}	{NotInteractive,Update,ElementDisposition}	posda_phi	Record a change to Element Disposition\nFor use in scripts\nNot really intended for interactive use\n
GetElementDispositionVR	select\n  element_signature_id, element_signature, vr, private_disposition as disposition, name_chain\nfrom\n  element_signature\nwhere\n  element_signature = ? and vr = ?\n	{element_signature,vr}	{element_signature_id,element_signature,vr,disposition,name_chain}	{NotInteractive,Update,ElementDisposition}	posda_phi	Get Disposition of element by sig and VR
ListOfPrivateElementsWithDispositions	select\n  element_signature, vr , private_disposition as disposition, element_signature_id, name_chain\nfrom\n  element_signature\nwhere\n  is_private\norder by element_signature\n	{}	{element_signature,vr,disposition,element_signature_id,name_chain}	{NotInteractive,Update,ElementDisposition}	posda_phi	Get Disposition of element by sig and VR
ValuesWithVrTagAndCount	select\n    distinct vr, value, element_signature, private_disposition, count(*)  as num_files\nfrom\n    scan_event natural join series_scan natural join seen_value\n    natural join element_signature natural join scan_element\nwhere\n    scan_event_id = ?\ngroup by value, element_signature, vr, private_disposition\n	{scan_id}	{vr,value,element_signature,private_disposition,num_files}	{tag_usage,PrivateTagKb}	posda_phi	List of values seen in scan by VR (with count of elements)\n
UpdateCountsDb	insert into totals_by_collection_site(\n  count_report_id,\n  collection_name, site_name,\n  num_subjects, num_studies, num_series, num_sops\n) values (\n  currval('count_report_count_report_id_seq'),\n  ?, ?,\n  ?, ?, ?, ?\n)\n	{project_name,site_name,num_subjects,num_studies,num_series,num_files}	\N	{intake,posda_counts}	posda_counts	
DistinctSeriesByCollectionLikePatient	select distinct patient_id, series_instance_uid, modality, count(*)\nfrom (\nselect distinct patient_id, series_instance_uid, sop_instance_uid, modality from (\nselect\n   distinct patient_id, series_instance_uid, modality, sop_instance_uid,\n   file_id\n from file_series natural join file_sop_common natural join file_patient\n   natural join ctp_file\nwhere\n  project_name = ? and patient_id like ?\n  and visibility is null)\nas foo\ngroup by patient_id, series_instance_uid, sop_instance_uid, modality)\nas foo\ngroup by patient_id, series_instance_uid, modality\n	{project_name,patient_id_like}	{patient_id,series_instance_uid,modality,count}	{by_collection,find_series}	posda_files	Get Series in A Collection\n
ListOfPrivateElementsValues	select\n  distinct value\nfrom\n  scan_element natural join seen_value\nwhere\n  element_signature_id = ?\norder by value\n	{element_signature_id}	{value}	{ElementDisposition}	posda_phi	Get List of Values for Private Element based on element_signature_id
DifferentDupSopsReceivedBetweenDatesByCollection	select * from (\nselect\n   distinct project_name, site_name, patient_id,\n   study_instance_uid, series_instance_uid, count(*) as num_sops,\n   sum(num_files) as num_files, sum(num_uploads) as num_uploads,\n    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\nfrom (\n  select \n    distinct project_name, site_name, patient_id,\n    study_instance_uid, series_instance_uid, sop_instance_uid,\n    count(*) as num_files, sum(num_uploads) as num_uploads,\n    min(first_loaded) as first_loaded, max(last_loaded) as last_loaded\n  from (\n    select\n      distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, count(*) as num_uploads, max(import_time) as last_loaded,\n         min(import_time) as first_loaded\n    from (\n      select\n        distinct project_name, site_name, patient_id,\n        study_instance_uid, series_instance_uid, sop_instance_uid,\n        file_id, import_time\n      from\n        ctp_file natural join file_patient natural join\n        file_study natural join file_series natural join\n        file_sop_common natural join file_import natural join\n        import_event\n      where\n        visibility is null and sop_instance_uid in (\n          select distinct sop_instance_uid\n          from \n            file_import natural join import_event natural join file_sop_common\n             natural join ctp_file\n          where import_time > ? and import_time < ?\n            and project_name = ? and visibility is null\n        )\n      ) as foo\n    group by\n      project_name, site_name, patient_id, study_instance_uid, \n      series_instance_uid, sop_instance_uid, file_id\n  )as foo\n  group by \n    project_name, site_name, patient_id, study_instance_uid, \n    series_instance_uid, sop_instance_uid\n) as foo\nwhere num_uploads > 1\ngroup by \n  project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid\n) as foo where num_sops != num_files\n	{start_time,end_time,collection}	{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,num_sops,num_files,num_uploads,first_loaded,last_loaded}	{receive_reports}	posda_files	Series received between dates with duplicate sops\n
GetPixelPaddingInfoByCollection	select\n  distinct modality, pixel_pad, slope, intercept, manufacturer, \n  image_type, pixel_representation as signed, count(*)\nfrom                                           \n  file_series natural join file_equipment natural join ctp_file natural join\n  file_slope_intercept natural join slope_intercept natural join file_image natural join image\nwhere                                                 \n  modality = 'CT' and project_name = ? and visibility is null\ngroup by \n  modality, pixel_pad, slope, intercept, manufacturer, image_type, signed\n	{collection}	{modality,pixel_pad,slope,intercept,manufacturer,image_type,signed,count}	{PixelPadding}	posda_files	Get Pixel Padding Summary Info\n
FirstFileInSeriesPublic	select\n  dicom_file_uri as path\nfrom\n  general_image\nwhere\n  series_instance_uid =  ?\nlimit 1\n	{series_instance_uid}	{path}	{by_series,UsedInPhiSeriesScan,public}	public	First files in series in Public\n
GetPixelPaddingInfo	select\n  distinct modality, pixel_pad, slope, intercept, manufacturer, \n  image_type, pixel_representation as signed, count(*)\nfrom                                           \n  file_series natural join file_equipment natural join \n  file_slope_intercept natural join slope_intercept natural join file_image natural join image\nwhere                                                 \n  modality = 'CT'\ngroup by \n  modality, pixel_pad, slope, intercept, manufacturer, image_type, signed\n	{}	{modality,pixel_pad,slope,intercept,manufacturer,image_type,signed,count}	{PixelPadding}	posda_files	Get Pixel Padding Summary Info\n
ListOfPublicElementsWithDispositionsBySopClassName	select\n  element_signature, vr , disposition, name_chain\nfrom\n  element_signature natural join public_disposition\nwhere\n  sop_class_uid = ? and name = ?\norder by element_signature\n	{sop_class_uid,name}	{element_signature,vr,disposition,name_chain}	{NotInteractive,Update,ElementDisposition}	posda_phi	Get Public Disposition of element by sig and VR for SOP Class and name
DistinctSeriesByCollectionPublic	select\n  distinct s.series_instance_uid, modality, count(*) as num_images\nfrom\n  general_image i, general_series s,\n  trial_data_provenance tdp\nwhere\n  s.general_series_pk_id = i.general_series_pk_id and\n  i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ?\ngroup by series_instance_uid, modality	{project_name}	{series_instance_uid,modality,num_images}	{by_collection,find_series,public}	public	Get Series in A Collection\n
ListOfPublicDispositionTables	select\n  distinct sop_class_uid, name, count(*)\nfrom\n  public_disposition\ngroup by\n  sop_class_uid, name\norder by\n  sop_class_uid, name	{}	{sop_class_uid,name,count}	{NotInteractive,ElementDisposition}	posda_phi	Get List of Public Disposition Tables
GetElementByPublicDisposition	select\n  element_signature, disposition\nfrom\n  element_signature natural join public_disposition\nwhere\n  sop_class_uid = ? and name = ? and\n  not is_private and disposition = ?\n	{sop_class_uid,name,disposition}	{element_signature,disposition}	{NotInteractive,ElementDisposition}	posda_phi	Get List of Public Elements By Disposition, Sop Class, and name
UploadCountsBetweenDatesByCollection	select distinct \n  project_name, site_name, patient_id, \n  study_instance_uid, series_instance_uid,\n  count(*)\nfrom\n  ctp_file natural join file_study\n  natural join file_series\n  natural join file_patient\nwhere file_id in (\n  select file_id\n  from\n    file_import natural join import_event\n    natural join ctp_file\n  where\n    import_time > ? and import_time < ? \n    and project_name = ?\n)\ngroup by\n  project_name, site_name, patient_id, \n  study_instance_uid, series_instance_uid\norder by \n  project_name, site_name, patient_id, \n  study_instance_uid, series_instance_uid\n 	{start_time,end_time,collection}	{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,count}	{receive_reports}	posda_files	Counts of uploads received between dates for a collection\nOrganized by Subject, Study, Series, count of files_uploaded\n
DistinctFilesByTagAndValue	select\n  distinct series_instance_uid,\n  series_scanned_file as file, \n  element_signature\nfrom\n  scan_event natural join series_scan natural join seen_value\n  natural join element_signature natural join \n  scan_element natural left join sequence_index\nwhere\n  element_signature = ? and value = ?\norder by series_instance_uid, file\n	{tag,value}	{series_instance_uid,file,element_signature}	{tag_usage}	posda_phi	Find out where specific value, tag combinations occur in a scan\n
GetValueForTagAllScans	select\n  distinct element_signature as tag, value\nfrom\n  scan_element natural join series_scan natural join\n  seen_value natural join element_signature\nwhere element_signature = ?\norder by value	{tag}	{tag,value}	{tag_values}	posda_phi	Find Values for a given tag for all scanned series in a phi scan instance\n
FilesByModalityByCollectionSite	select\n  distinct patient_id, modality, series_instance_uid, sop_instance_uid, root_path || '/' || rel_path as path\nfrom\n  file_patient natural join file_series natural join file_sop_common natural join ctp_file\n  natural join file_location natural join file_storage_root\nwhere\n  modality = ? and\n  project_name = ? and \n  site_name = ? and\n  visibility is null	{modality,project_name,site_name}	{patient_id,modality,series_instance_uid,sop_instance_uid,path}	{FindSubjects,intake,FindFiles}	posda_files	Find All Files with given modality in Collection, Site
GetElementByPrivateDisposition	select\n  element_signature, private_disposition as disposition\nfrom\n  element_signature\nwhere\n  is_private and private_disposition = ?\n	{private_disposition}	{element_signature,disposition}	{NotInteractive,ElementDisposition}	posda_phi	Get List of Private Elements By Disposition
ValuesByVrWithTagAndCount	select distinct value, element_signature, private_disposition, num_files from (\n  select\n    distinct value, element_signature, private_disposition, vr, count(*)  as num_files\n  from\n    scan_event natural join series_scan natural join seen_value\n    natural join element_signature natural join scan_element\n  where\n    scan_event_id = ? and vr = ?\n  group by value, element_signature, vr\n) as foo\norder by value\n	{scan_id,vr}	{value,element_signature,private_disposition,num_files}	{tag_usage}	posda_phi	List of values seen in scan by VR (with count of elements)\n
SeriesByNotLikeDescriptionAndCollectionSite	select distinct\n  series_instance_uid, series_description\nfrom\n  file_series natural join ctp_file\nwhere \n  project_name = ? and site_name = ? and \n  visibility is null and\n  series_description not like ?\n	{collection,site,pattern}	{series_instance_uid,series_description}	{find_series}	posda_files	Get a list of Series by Collection, Site not matching Series Description\n
PixelTypesWithRowsColumns	select\n  distinct photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  pixel_rows,\n  pixel_columns,\n  number_of_frames,\n  pixel_representation,\n  planar_configuration,\n  modality,\n  count(*)\nfrom\n  image natural join file_image natural join file_series\ngroup by\n  photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  pixel_rows,\n  pixel_columns,\n  number_of_frames,\n  pixel_representation,\n  planar_configuration,\n  modality\norder by\n  count desc	{}	{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_rows,pixel_columns,number_of_frames,pixel_representation,planar_configuration,modality,count}	{all,find_pixel_types,posda_files}	posda_files	Get distinct pixel types\n
SlopeInterceptByPixelType	select \n  distinct slope, intercept, count(*)\nfrom (select\n    distinct photometric_interpretation,\n    samples_per_pixel,\n    bits_allocated,\n    bits_stored,\n    high_bit,\n    coalesce(number_of_frames,1) > 1 as is_multi_frame,\n    pixel_representation,\n    planar_configuration,\n    modality,\n    file_id\n  from\n    image natural join file_image natural join file_series\n  ) as foo natural join file_slope_intercept natural join slope_intercept\nwhere\n  photometric_interpretation = ? and\n  samples_per_pixel = ? and\n  bits_allocated = ? and\n  bits_stored = ? and\n  high_bit = ? and\n  pixel_representation = ? and\n  modality = ?\ngroup by slope, intercept\n	{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,modality}	{slope,intercept,count}	{all,find_pixel_types,posda_files}	posda_files	Get distinct pixel types\n
UpdateEquivalenceClassProcessingStatus	update image_equivalence_class\nset processing_status = ?\nwhere image_equivalence_class_id = ?\n	{processing_status,image_equivalence_class_id}	{}	{consistency,find_series,equivalence_classes,NotInteractive}	posda_files	For building series equivalence classes
RelinquishBacklogControl	update control_status\nset status = 'idle',\n  processor_pid =  null,\n  pending_change_request = null,\n  source_pending_change_request = null,\n  request_time = null	{}	{}	{NotInteractive,Backlog}	posda_backlog	relese control of posda_backlog
InsertInitialPatientStatus	insert into patient_import_status(\n  patient_id, patient_import_status\n) values (?, ?)\n	{patient_id,status}	\N	{Insert,NotInteractive,PatientStatus}	posda_files	Insert Initial Patient Status\nFor use in scripts\nNot really intended for interactive use\n
GetSimpleSeriesScanId	select currval('series_scan_instance_series_scan_instance_id_seq') as id	{}	{id}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Get id of newly created series_scan_instance
FinalizeSimpleSeriesScan	update series_scan_instance set\n  num_files = ?,\n  end_time = now()\nwhere\n  series_scan_instance_id = ?	{num_files,id}	{}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Finalize Series Scan
GetElementByPrivateDispositionSimple	select\n  element_sig_pattern as element_signature, private_disposition as disposition\nfrom\n  element_seen\nwhere\n  is_private and private_disposition = ?\n	{private_disposition}	{element_signature,disposition}	{NotInteractive,ElementDisposition}	posda_phi_simple	Get List of Private Elements By Disposition
FindStudiesWithMatchingDescriptionByCollection	select distinct study_instance_uid from (\n  select distinct study_instance_uid, count(*) from (\n    select distinct\n      study_instance_uid, study_date, study_time,\n      referring_phy_name, study_id, accession_number,\n      study_description, phys_of_record, phys_reading,\n      admitting_diag\n    from\n      file_study natural join ctp_file\n    where\n      project_name = ? and visibility is null and study_description = ?\n    group by\n      study_instance_uid, study_date, study_time,\n      referring_phy_name, study_id, accession_number,\n      study_description, phys_of_record, phys_reading,\n      admitting_diag\n  ) as foo\n  group by study_instance_uid\n) as foo\nwhere count > 1\n	{collection,description}	{study_instance_uid}	{by_study,consistency}	posda_files	Find Studies by Collection with Null Study Description\n
FindFilesInStudyWithDescriptionByStudyUID	select distinct\n  study_instance_uid, study_date, study_time,\n  referring_phy_name, study_id, accession_number,\n  study_description, phys_of_record, phys_reading,\n  admitting_diag, count(*)\nfrom\n  file_study natural join ctp_file\nwhere study_instance_uid = ? and visibility is null\ngroup by\n  study_instance_uid, study_date, study_time,\n  referring_phy_name, study_id, accession_number,\n  study_description, phys_of_record, phys_reading,\n  admitting_diag\n	{study_instance_uid}	{study_instance_uid,count,study_description,study_date,study_time,referring_phy_name,study_id,accession_number,phys_of_record,phys_reading,admitting_diag}	{by_study,consistency}	posda_files	Find SopInstanceUID and Description for All Files In Study\n
WindowLevelByPixelType	select \n  distinct window_width, window_center, count(*)\nfrom (select\n    distinct photometric_interpretation,\n    samples_per_pixel,\n    bits_allocated,\n    bits_stored,\n    high_bit,\n    coalesce(number_of_frames,1) > 1 as is_multi_frame,\n    pixel_representation,\n    planar_configuration,\n    modality,\n    file_id\n  from\n    image natural join file_image natural join file_series\n  ) as foo natural join file_win_lev natural join window_level\nwhere\n  photometric_interpretation = ? and\n  samples_per_pixel = ? and\n  bits_allocated = ? and\n  bits_stored = ? and\n  high_bit = ? and\n  pixel_representation = ? and\n  modality = ?\ngroup by window_width, window_center\n	{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,modality}	{window_width,window_center,count}	{all,find_pixel_types,posda_files}	posda_files	Get distinct pixel types\n
FindStudiesWithNullDescriptionByCollection	select distinct study_instance_uid from (\n  select distinct study_instance_uid, count(*) from (\n    select distinct\n      study_instance_uid, study_date, study_time,\n      referring_phy_name, study_id, accession_number,\n      study_description, phys_of_record, phys_reading,\n      admitting_diag\n    from\n      file_study natural join ctp_file\n    where\n      project_name = ? and visibility is null and study_description is null\n    group by\n      study_instance_uid, study_date, study_time,\n      referring_phy_name, study_id, accession_number,\n      study_description, phys_of_record, phys_reading,\n      admitting_diag\n  ) as foo\n  group by study_instance_uid\n) as foo\nwhere count > 1\n	{collection}	{study_instance_uid}	{by_study,consistency}	posda_files	Find Studies by Collection with Null Study Description\n
PatientStudySeriesHierarchyByCollection	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid\nfrom\n  file_study natural join ctp_file natural join file_series natural join file_patient\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file\n    where project_name = ? and visibility is null\n  )\norder by patient_id, study_instance_uid, series_instance_uid	{collection}	{patient_id,study_instance_uid,series_instance_uid}	{Hierarchy}	posda_files	Construct list of files in a collection in a Patient, Study, Series Hierarchy
PatientStudySeriesFileHierarchyByCollection	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid,\n  sop_instance_uid,\n  root_path || '/' || rel_path as path\nfrom\n  file_study natural join ctp_file natural join file_series natural join file_patient\n  natural join file_sop_common natural join file_location\n  natural join file_storage_root\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file\n    where project_name = ? and visibility is null\n  )\norder by patient_id, study_instance_uid, series_instance_uid	{collection}	{patient_id,study_instance_uid,series_instance_uid,path}	{Hierarchy}	posda_files	Construct list of files in a collection in a Patient, Study, Series Hierarchy
ListOfPrivateElementsWithDispositionsByScanId	select\n  distinct element_signature, vr , private_disposition as disposition,\n  element_signature_id, name_chain\nfrom\n  element_signature natural join scan_element natural join series_scan\nwhere\n  is_private and scan_event_id = ?\norder by element_signature\n	{scan_id}	{element_signature,vr,disposition,element_signature_id,name_chain}	{NotInteractive,Update,ElementDisposition}	posda_phi	Get Disposition of element by sig and VR
ListOfPrivateElementsWithNullDispositionsByScanId	select\n  distinct element_signature, vr , private_disposition as disposition,\n  element_signature_id, name_chain\nfrom\n  element_signature natural join scan_element natural join series_scan\nwhere\n  is_private and scan_event_id = ? and private_disposition is null\norder by element_signature\n	{scan_id}	{element_signature,vr,disposition,element_signature_id,name_chain}	{NotInteractive,Update,ElementDisposition}	posda_phi	Get Disposition of element by sig and VR
AllPublicSignaturesByScanId	select distinct element_signature as public_signature\nfrom\n  scan_event natural join series_scan\n  natural join scan_element natural join element_signature\nwhere\n  scan_event_id = ? \n  and not is_private\norder by public_signature	{scan_id}	{public_signature}	{tag_usage}	posda_phi	List of non-private Element Signatures seen by Scan
DistinctSeriesByCollectionExceptModality	select distinct series_instance_uid, modality, count(*)\nfrom (\nselect distinct series_instance_uid, sop_instance_uid, modality from (\nselect\n   distinct series_instance_uid, modality, sop_instance_uid,\n   file_id\n from file_series natural join file_sop_common\n   natural join ctp_file\nwhere\n  project_name = ? and modality != ?\n  and visibility is null)\nas foo\ngroup by series_instance_uid, sop_instance_uid, modality)\nas foo\ngroup by series_instance_uid, modality\n	{project_name,modality}	{series_instance_uid,modality,count}	{by_collection,find_series}	posda_files	Get Series in A Collection with modality other than specified\n
SeriesConsistencyExtended	select distinct\n  series_instance_uid, modality, series_number, laterality, series_date, dicom_file_type,\n  series_time, performing_phys, protocol_name, series_description,\n  operators_name, body_part_examined, patient_position,\n  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n  performed_procedure_step_start_date, performed_procedure_step_start_time,\n  performed_procedure_step_desc, performed_procedure_step_comments, image_type,\n  iop, pixel_rows, pixel_columns,\n  count(*)\nfrom\n  file_series natural join ctp_file natural join dicom_file\n  left join file_image using(file_id)\n  left join image using (image_id)\n  left join image_geometry using (image_id)\nwhere series_instance_uid = ? and visibility is null\ngroup by\n  series_instance_uid, dicom_file_type, modality, series_number, laterality,\n  series_date, image_type, iop, pixel_rows, pixel_columns,\n  series_time, performing_phys, protocol_name, series_description,\n  operators_name, body_part_examined, patient_position,\n  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n  performed_procedure_step_start_date, performed_procedure_step_start_time,\n  performed_procedure_step_desc, performed_procedure_step_comments\n	{series_instance_uid}	{series_instance_uid,count,dicom_file_type,modality,laterality,series_number,series_date,image_type,series_time,performing_phys,protocol_name,series_description,operators_name,body_part_examined,patient_position,smallest_pixel_value,largest_pixel_value,performed_procedure_step_id,performed_procedure_step_start_date,performed_procedure_step_start_time,performed_procedure_step_desc,performed_procedure_step_comments,iop,pixel_rows,pixel_columns}	{by_series,consistency}	posda_files	Check a Series for Consistency (including Image Type)\n
PrivateTagValuesWithVrTagAndCountWhereDispositionIsNull	select\n  distinct vr , value, element_signature, private_disposition, count(*) as num_files\nfrom\n  element_signature natural left join scan_element natural left join series_scan natural left join seen_value\nwhere\n  is_private and private_disposition is null\ngroup by\n  vr, value, element_signature, private_disposition\n	{}	{vr,value,element_signature,private_disposition,count}	{DispositionReport,NotInteractive}	posda_phi	Get the disposition of a public tag by signature\nUsed in DispositionReport.pl - not for interactive use\n
ListOfPrivateElementsWithNullDispositions	select\n  distinct element_signature, vr , private_disposition as disposition,\n  element_signature_id, name_chain\nfrom\n  element_signature natural join scan_element natural join series_scan\nwhere\n  is_private and private_disposition is null\norder by element_signature\n	{}	{element_signature,vr,disposition,element_signature_id,name_chain}	{NotInteractive,Update,ElementDisposition}	posda_phi	Get Disposition of element by sig and VR
InsertInitialDicomDD	insert into dicom_element(tag, name, keyword, vr, vm, is_retired, comments)\nvalues (?,?,?,?,?,?,?)	{tag,name,keyword,vr,vm,is_retired,comments}	{}	{Insert,NotInteractive,dicom_dd}	dicom_dd	Insert row into dicom_dd database
DicomFileTypesNotProcessed	select \n  distinct dicom_file_type, count(distinct file_id)\nfrom\n  dicom_file d natural join ctp_file\nwhere\n  visibility is null  and\n  not exists (\n    select file_id \n    from file_series s\n    where s.file_id = d.file_id\n  )\ngroup by dicom_file_type	{}	{dicom_file_type,count}	{dicom_file_type}	posda_files	List of Distinct Dicom File Types which have unprocessed DICOM files\n
DistinctSeriesByDicomFileType	select \n  distinct series_instance_uid, dicom_file_type, count(distinct file_id)\nfrom\n  file_series natural join dicom_file natural join ctp_file\nwhere\n  dicom_file_type = ? and\n  visibility is null  \ngroup by series_instance_uid, dicom_file_type	{dicom_file_type}	{series_instance_uid,dicom_file_type,count}	{find_series,dicom_file_type}	posda_files	List of Distinct Series By Dicom File Type\n
DicomFileTypesNotProcessedAll	select \n  distinct dicom_file_type, count(distinct file_id)\nfrom\n  dicom_file d\nwhere\n  not exists (\n    select file_id \n    from file_series s\n    where s.file_id = d.file_id\n  )\ngroup by dicom_file_type	{}	{dicom_file_type,count}	{dicom_file_type}	posda_files	List of Distinct Dicom File Types which have unprocessed DICOM files\n
IntakeCountsOld	select\n        p.patient_id as PID,\n        i.image_type as ImageType,\n        s.modality as Modality,\n        count(i.sop_instance_uid) as Images,\n        t.study_date as StudyDate,\n        t.study_desc as StudyDescription,\n        s.series_desc as SeriesDescription,\n        s.series_number as SeriesNumber,\n        t.study_instance_uid as StudyInstanceUID,\n        s.series_instance_uid as SeriesInstanceUID,\n        q.manufacturer as Mfr,\n        q.manufacturer_model_name as Model,\n        q.software_versions,\n        c.reconstruction_diameter as ReconstructionDiameter,\n        c.kvp as KVP,\n        i.slice_thickness as SliceThickness\n     from\n        general_image i,\n        general_series s,\n        study t,\n        patient p,\n        trial_data_provenance tdp,\n        general_equipment q,\n        ct_image c\n     where\n        i.general_series_pk_id = s.general_series_pk_id and\n        s.study_pk_id = t.study_pk_id and\n        s.general_equipment_pk_id = q.general_equipment_pk_id and\n        t.patient_pk_id = p.patient_pk_id and\n        p.trial_dp_pk_id = tdp.trial_dp_pk_id and\n        tdp.project = ? and\n        tdp.dp_site_name = ? and\n        c.image_pk_id = i.image_pk_id\n    group by p.patient_id, i.image_type, s.series_instance_uid, t.study_instance_uid\n	{collection,site}	{PID,Modality,Images,StudyDate,StudyDescription,SeriesDescription,SeriesNumber,StudyInstanceUID,SeriesInstanceUID,Mfr,Model,software_versions,ImageType,ReconstructionDiameter,KVP,SliceThickness}	{intake}	intake	List of all Files Images By Collection, Site\n
FilesInSeriesForApplyingPrivateDisposition	select\n  distinct file_id, root_path || '/' || rel_path as path, sop_instance_uid, \n  modality\nfrom\n  file_location natural join file_storage_root\n  natural join ctp_file\n  natural join file_sop_common natural join file_series\nwhere\n  series_instance_uid = ? and visibility is null\n	{series_instance_uid}	{path,sop_instance_uid,modality}	{SeriesSendEvent,by_series,find_files,ApplyDisposition}	posda_files	Get Sop Instance UID, file_path, modality for all files in a series
FilesInCollectionSiteForApplicationOfPrivateDisposition	select\n  distinct file_id, root_path || '/' || rel_path as path, \n  patient_id, study_instance_uid, series_instance_uid,\n  sop_instance_uid\nfrom\n  file_location natural join file_storage_root natural join file_patient\n  natural join ctp_file natural join file_study \n  natural join file_sop_common natural join file_series\n  \nwhere\n  project_name = ? and site_name = ? and visibility is null\n	{collection,site}	{file_id,path,patient_id,study_instance_uid,series_instance_uid,sop_instance_uid}	{by_collection_site,find_files}	posda_files	Get everything you need to negotiate a presentation_context\nfor all files in a Collection Site\n
FilesInSeriesForApplicationOfPrivateDisposition	select\n  distinct root_path || '/' || rel_path as path, \n  sop_instance_uid, modality\nfrom\n  file_location natural join file_storage_root \n  natural join ctp_file natural join file_series\n  natural join file_sop_common\nwhere\n  series_instance_uid = ? and visibility is null\n	{series_instance_uid}	{path,sop_instance_uid,modality}	{find_files,ApplyDisposition}	posda_files	Get path, sop_instance_uid, and modality for all files in a series\n
DicomFileTypes	select \n  distinct dicom_file_type, count(distinct file_id)\nfrom\n  dicom_file natural join ctp_file\nwhere\n  visibility is null  \ngroup by dicom_file_type\norder by count desc	{}	{dicom_file_type,count}	{find_series,dicom_file_type}	posda_files	List of Dicom File Types with count of files in Posda\n
SeriesInCollectionSiteForApplicationOfPrivateDisposition	select\n  distinct \n  patient_id, study_instance_uid, series_instance_uid\nfrom\n  file_patient natural join ctp_file natural join file_study \n  natural join file_sop_common natural join file_series\nwhere\n  collection = ? and site = ? and visibility is null\n	{collection,site}	{patient_id,study_instance_uid,series_instance_uid}	{by_collection_site,find_files}	posda_files	Get a patient, study, series hierarchy by collection, site
PatientStudySeriesHierarchyByCollectionNotMatchingSeriesDesc	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid\nfrom\n  file_study natural join ctp_file natural join file_series natural join file_patient\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file natural join file_series\n    where project_name = ? and visibility is null and series_description not like ?\n  )\norder by patient_id, study_instance_uid, series_instance_uid	{collection,exclude_series_descriptions_matching}	{patient_id,study_instance_uid,series_instance_uid}	{Hierarchy}	posda_files	Construct list of series in a collection in a Patient, Study, Series Hierarchy excluding matching SeriesDescriptons
PatientStudySeriesFileHierarchyByCollectionExcludingSeriesByDescription	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid,\n  sop_instance_uid,\n  root_path || '/' || rel_path as path\nfrom\n  file_study natural join ctp_file natural join file_series natural join file_patient\n  natural join file_sop_common natural join file_location\n  natural join file_storage_root\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file natural join file_series\n    where project_name = ? and visibility is null and series_description not like ?\n  )\norder by patient_id, study_instance_uid, series_instance_uid	{collection,exclude_series_descriptions_matching}	{patient_id,study_instance_uid,series_instance_uid,path}	{Hierarchy}	posda_files	Construct list of files in a collection in a Patient, Study, Series Hierarchy excluding series by series_description
CollectionSiteWithDicomFileTypesNotProcessed	select \n  distinct project_name as collection, site_name as site, dicom_file_type, count(distinct file_id)\nfrom\n  dicom_file d natural join ctp_file\nwhere\n  visibility is null  and\n  not exists (\n    select file_id \n    from file_series s\n    where s.file_id = d.file_id\n  )\ngroup by project_name, site_name, dicom_file_type	{}	{collection,site,dicom_file_type,count}	{dicom_file_type}	posda_files	List of Distinct Collection, Site, Dicom File Types which have unprocessed DICOM files\n
ForConstructingSeriesEquivalenceClasses	select distinct\n  series_instance_uid, modality, series_number, laterality, series_date, dicom_file_type,\n  performing_phys, protocol_name, series_description,\n  operators_name, body_part_examined, patient_position,\n  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n  performed_procedure_step_start_date\n  performed_procedure_step_desc, performed_procedure_step_comments, image_type,\n  iop, pixel_rows, pixel_columns,\n  file_id\nfrom\n  file_series natural join ctp_file natural join dicom_file\n  left join file_image using(file_id)\n  left join image using (image_id)\n  left join image_geometry using (image_id)\nwhere series_instance_uid = ? and visibility is null\n	{series_instance_uid}	{series_instance_uid,modality,series_number,laterality,series_date,dicom_file_type,performing_phys,protocol_name,series_description,operators_name,body_part_examined,patient_position,smallest_pixel_value,largest_pixel_value,performed_procedure_step_id,performed_procedure_step_start_date,performed_procedure_step_desc,performed_procedure_step_comments,image_type,iop,pixel_rows,pixel_columns,file_id}	{consistency,find_series,equivalence_classes}	posda_files	For building series equivalence classes
CreateEquivalenceClass	insert into image_equivalence_class(\n  series_instance_uid, equivalence_class_number,\n  processing_status\n) values (\n  ?, ?, 'Preparing'\n)\n	{series_instance_uid,equivalence_class_number}	{}	{consistency,find_series,equivalence_classes,NotInteractive}	posda_files	For building series equivalence classes
GetEquivalenceClassId	select currval('image_equivalence_class_image_equivalence_class_id_seq') as id	{}	{id}	{NotInteractive,equivalence_classes}	posda_files	Get current value of EquivalenceClassId Sequence\n
CreateEquivalenceInputClass	insert into image_equivalence_class_input_image(\n  image_equivalence_class_id,  file_id\n) values (\n  ?, ?\n)\n	{image_equivlence_class_id,file_id}	{}	{consistency,equivalence_classes,NotInteractive}	posda_files	For building series equivalence classes
UpdateEquivalenceClassReviewStatus	update image_equivalence_class\nset review_status = ?\nwhere image_equivalence_class_id = ?\n	{processing_status,image_equivalence_class_id}	{}	{consistency,find_series,equivalence_classes,NotInteractive}	posda_files	For building series equivalence classes
SeriesFileByCollectionWithNoEquivalenceClass	select distinct\n  series_instance_uid\nfrom\n  file_series s\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file\n    where project_name = ? and visibility is null\n  )\n  and not exists (\n    select \n      series_instance_uid\n   from\n      image_equivalence_class e\n   where\n      e.series_instance_uid = s.series_instance_uid\n )	{collection}	{series_instance_uid}	{equivalence_classes}	posda_files	Construct list of series in a collection where no image_equivalence_class exists
InsertPublicDisposition	insert into public_disposition(\n  element_signature_id, sop_class_uid, name, disposition\n) values (\n  ?, ?, ?, ?\n)\n\n	{element_signature_id,sop_class_uid,name,disposition}	{}	{NotInteractive,Update,ElementDisposition}	posda_phi	Insert a public disposition
ClearPublicDispositions	delete from public_disposition where\n  sop_class_uid = ? and name = ?\n\n	{sop_class_uid,name}	{}	{NotInteractive,Update,ElementDisposition}	posda_phi	Clear all public dispositions for a give sop_class and name
GetPublicFeaturesBySignature	select\n  name, vr\nfrom dicom_element\nwhere tag = ?	{element_signature}	{name,vr}	{UsedInPhiSeriesScan,NotInteractive,ElementDisposition}	dicom_dd	Get Element Signature By Signature (pattern) and VR
CountsByCollectionSiteExcludingSeriesByDescription	select\n  distinct\n    patient_id, image_type, modality, study_date, study_description,\n    series_description, study_instance_uid, series_instance_uid,\n    manufacturer, manuf_model_name, software_versions,\n    count(distinct sop_instance_uid) as num_sops,\n    count(distinct file_id) as num_files\nfrom\n  ctp_file join file_patient using(file_id)\n  join file_series using(file_id)\n  join file_sop_common using(file_id)\n  join file_study using(file_id)\n  join file_equipment using(file_id)\n  left join file_image using(file_id)\n  left join image using (image_id)\nwhere\n  project_name = ? and site_name = ? and visibility is null and\n  series_description not like ?\ngroup by\n  patient_id, image_type, modality, study_date, study_description,\n  series_description, study_instance_uid, series_instance_uid,\n  manufacturer, manuf_model_name, software_versions\norder by\n  patient_id, study_instance_uid, series_instance_uid, image_type,\n  modality, study_date, study_description,\n  series_description,\n  manufacturer, manuf_model_name, software_versions\n	{collection,site,series_description_exclusion_pattern}	{patient_id,image_type,modality,study_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files}	{counts}	posda_files	Counts query by Collection, Site\n
SeriesWithMoreThanNEquivalenceClasses	select series_instance_uid, count from (\nselect distinct series_instance_uid, count(*) from image_equivalence_class group by series_instance_uid) as foo where count > ?	{count}	{series_instance_uid,count}	{find_series,equivalence_classes,consistency}	posda_files	Find Series with more than n equivalence class
GetValueForTagBySeries	select\n  distinct series_instance_uid, element_signature as tag, value\nfrom\n  series_scan natural join scan_element natural join seen_value natural join element_signature\nwhere\n  series_instance_uid = ? and element_signature = ?	{series_instance_uid,tag}	{series_instance_uid,tag,value}	{tag_values}	posda_phi	Find Distinct value for a given tag for a particular scanned series\n
PatientStudySeriesFileHierarchyByCollectionIncludingSeriesByDescription	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid,\n  sop_instance_uid,\n  root_path || '/' || rel_path as path\nfrom\n  file_study natural join ctp_file natural join file_series natural join file_patient\n  natural join file_sop_common natural join file_location\n  natural join file_storage_root\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file natural join file_series\n    where project_name = ? and visibility is null and series_description like ?\n  )\norder by patient_id, study_instance_uid, series_instance_uid	{collection,exclude_series_descriptions_matching}	{patient_id,study_instance_uid,series_instance_uid,path}	{Hierarchy}	posda_files	Construct list of files in a collection in a Patient, Study, Series Hierarchy excluding series by series_description
GoInService	update control_status\nset status = 'service process running',\n  processor_pid = ?	{pid}	{}	{NotInteractive,Backlog}	posda_backlog	Claim control of posda_backlog
ShowAllVisibilityChangesBySeriesInstance	select\n  distinct\n  user_name,\n  time_of_change,\n  prior_visibility,\n  new_visibility,\n  reason_for,\n  count (distinct file_id) as num_files\nfrom\n   file_visibility_change \nwhere file_id in (\n  select distinct file_id \n  from file_series\n  where series_instance_uid = ?\n)\ngroup by user_name, time_of_change,\n  prior_visibility, new_visibility, reason_for\norder by time_of_change	{series_instance_uid}	{user_name,time_of_change,prior_visibility,new_visibility,reason_for,num_files}	{show_hidden}	posda_files	Show All Hide Events by Collection, Site
InsertIntoFileRoiImageLinkage	insert into file_roi_image_linkage(\n  file_id,\n  roi_id,\n  linked_sop_instance_uid,\n  linked_sop_class_uid,\n  contour_file_offset,\n  contour_length,\n  contour_digest,\n  num_points,\n  contour_type\n) values (\n  ?, ?, ?, ?, ?, ?, ?, ?, ?\n)	{file_id,roi_id,linked_sop_instance_uid,linked_sop_class_uid,contour_file_offset,contour_length,contour_digest,num_points,contour_type}	{}	{NotInteractive,used_in_processing_structure_set_linkages}	posda_files	Get the file_storage root for newly created files
SeriesEquivalenceClassNoByProcessingStatus	select \n  distinct series_instance_uid, equivalence_class_number, count(*) \nfrom \n  image_equivalence_class natural join image_equivalence_class_input_image\nwhere\n  processing_status = ?\ngroup by series_instance_uid, equivalence_class_number\norder by series_instance_uid, equivalence_class_number	{processing_status}	{series_instance_uid,equivalence_class_number,count}	{find_series,equivalence_classes,consistency}	posda_files	Find Series with more than n equivalence class
SeriesWithExactlyNEquivalenceClasses	select series_instance_uid, count from (\nselect distinct series_instance_uid, count(*) from image_equivalence_class group by series_instance_uid) as foo where count = ?	{count}	{series_instance_uid,count}	{find_series,equivalence_classes,consistency}	posda_files	Find Series with exactly n equivalence classes
InsertCollectionCountPerRound	insert into collection_count_per_round(\n  collection, file_count\n) values (\n  ?, ?\n)\n	{collection,num_files}	{}	{NotInteractive,Backlog}	posda_backlog	Insert a row into collection count per round
ListOfValuesByElementInScan	select element_signature, value                  \nfrom element_signature natural join scan_element natural join seen_value natural join series_scan natural join scan_event where element_signature = ? and scan_event_id = ?;	{element_signature,scan_id}	{element_signature,value}	{ElementDisposition}	posda_phi	Get List of Values for Private Element based on element_signature_id
PatientStudySeriesFileHierarchyByCollectionSite	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid,\n  sop_instance_uid,\n  modality\nfrom\n  file_study natural join ctp_file natural join file_series natural join file_patient\n  natural join file_sop_common\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file\n    where project_name = ? and site_name = ? and visibility is null\n  )\norder by patient_id, study_instance_uid, series_instance_uid	{collection,site}	{patient_id,study_instance_uid,series_instance_uid,modality}	{Hierarchy}	posda_files	Construct list of files in a collection, site in a Patient, Study, Series, with Modality of file
PatientStudySeriesEquivalenceClassNoByProcessingStatus	select \n  distinct patient_id, study_instance_uid, series_instance_uid, equivalence_class_number, count(*) \nfrom \n  image_equivalence_class natural join image_equivalence_class_input_image natural join\n  file_study natural join file_series natural join file_patient\nwhere\n  processing_status = ?\ngroup by patient_id, study_instance_uid, series_instance_uid, equivalence_class_number\norder by patient_id, study_instance_uid, series_instance_uid, equivalence_class_number	{processing_status}	{patient_id,study_instance_uid,series_instance_uid,equivalence_class_number,count}	{find_series,equivalence_classes,consistency,visual_review}	posda_files	Find Series with more than n equivalence class
GetListCollectionsWithNoDefinedCounts	select distinct collection\nfrom submitter s\nwhere collection not in (\n  select collection from collection_count_per_round c\n  where s.collection = c.collection\n)\n	{}	{collection}	{NotInteractive,Backlog,"Backlog Monitor"}	posda_backlog	Get a list of all collections in backlog with no defined counts
MakeBacklogReadyForProcessing	update control_status\n  set status = 'waiting to go inservice'\n	{}	{}	{NotInteractive,Backlog,"Backlog Monitor"}	posda_backlog	Mark Backlog as ready for Processor
GetPrivateTagNameAndVrBySignature	select\n  pt_consensus_name as name,\n  pt_consensus_vr as vr\nfrom pt\nwhere pt_signature = ?\n	{signature}	{name,vr}	{DispositionReport,NotInteractive,used_in_reconcile_tag_names}	posda_private_tag	Get the relevant features of a private tag by signature\nUsed in DispositionReport.pl - not for interactive use\n
GetPublicTagNameAndVrBySignature	select\n  name,\n  vr\nfrom dicom_element\nwhere tag = ?\n	{tag}	{name,vr}	{DispositionReport,NotInteractive,used_in_reconcile_tag_names}	dicom_dd	Get the relevant features of a private tag by signature\nUsed in DispositionReport.pl - not for interactive use\n
GetPosdaPhiElementSigInfo	select\n  element_signature,\n  vr,\n  is_private,\n  private_disposition,\n  name_chain\nfrom element_signature\n\n	{}	{element_signature,vr,is_private,private_disposition,name_chain}	{NotInteractive,used_in_reconcile_tag_names}	posda_phi	Get the relevant features of an element_signature in posda_phi schema
GetPosdaPhiSimpleElementSigInfo	select\n  element_sig_pattern,\n  vr,\n  is_private,\n  private_disposition,\n  tag_name\nfrom element_seen\n\n	{}	{element_sig_pattern,vr,is_private,private_disposition,name_chain}	{NotInteractive,used_in_reconcile_tag_names}	posda_phi_simple	Get the relevant features of an element_signature in posda_phi_simple schema
UpdPosdaPhiEleName	update\n  element_signature\nset\n  name_chain = ?\nwhere\n  element_signature = ? and\n  vr = ?\n\n	{name,element_signature,vr}	{}	{NotInteractive,used_in_reconcile_tag_names}	posda_phi	Update name_chain in element signature
UpdPosdaPhiSimpleEleName	update\n  element_seen\nset\n  tag_name = ?,\n  is_private = ?\nwhere\n  element_sig_pattern = ? and\n  vr = ?\n\n	{name,is_private,element_signature,vr}	{}	{NotInteractive,used_in_reconcile_tag_names}	posda_phi_simple	Update name_chain in element_seen
StartTransactionPosda	begin\n	{}	{}	{NotInteractive,Backlog,Transaction,used_in_file_import_into_posda}	posda_files	Start a transaction in Posda files
UpdateCollectionBacklogPrio	update\n  collection_count_per_round\nset\n  file_count = ?\nwhere\n  collection = ?\n\n	{priority,collection}	{}	{NotInteractive,Backlog}	posda_backlog	Update the priority of a collection in a backlog 
LockFilePosda	LOCK file in ACCESS EXCLUSIVE mode	{}	{}	{NotInteractive,Backlog,Transaction,used_in_file_import_into_posda}	posda_files	Lock the file table in posda_files
GetNRequestsForCollection	select \n  distinct request_id, collection, received_file_path, file_digest, time_received, size\nfrom \n  request natural join submitter\nwhere\n  collection = ? and not file_in_posda \norder by time_received \nlimit ?\n	{collection,num_rows}	{request_id,collection,received_file_path,file_digest,time_received,size}	{NotInteractive,Backlog}	posda_backlog	Get N Requests for a Given Collection
GetAllFilesAndDigests	select \n  received_file_path, file_digest\nfrom \n  request\n\n	{}	{received_file_path,digest}	{NotInteractive,Backlog}	posda_backlog	Get all files with digests in backlog
GetPosdaQueueSize	select\n count(*) as num_files\nfrom\n  file NATURAL JOIN file_location NATURAL JOIN file_storage_root\nwhere\n  is_dicom_file is null and\n  ready_to_process and\n  processing_priority is not null\n\n	{}	{num_files}	{NotInteractive,Backlog,"Backlog Monitor",backlog_status}	posda_files	Get size of queue  in Posda
InsertFileImport	insert into file_import(\n  import_event_id, file_id,  file_name\n) values (\n  currval('import_event_import_event_id_seq'),?, ?\n)\n	{file_id,file_name}	{}	{NotInteractive,Backlog}	posda_files	Create an import_event
GetPosdaFileStorageRoots	select\n file_storage_root_id as id, root_path as root, current, storage_class\nfrom\n  file_storage_root\n	{}	{id,root,current,storage_class}	{NotInteractive,Backlog}	posda_files	Get Posda File Storage Roots
InsertFilePosda	insert into file(\n  digest, size, processing_priority, ready_to_process\n) values ( ?, ?, 1, 'false')	{digest,size}	{}	{NotInteractive,Backlog,Transaction,used_in_file_import_into_posda}	posda_files	Lock the file table in posda_files
InsertRoundCollection	insert into round_collection(\n  round_id, collection,\n  num_entered, num_failed,\n  num_dups\n) values (\n  ?, ?,\n  ?, ?,\n  ?\n)\n	{round_id,collection,num_entered,num_failed,num_dups}	{}	{NotInteractive,Backlog}	posda_backlog	Insert a row into round_collection
CloseRound	update round\n  set round_end = now()\nwhere\n  round_id = ?\n	{round_id}	{}	{NotInteractive,Backlog}	posda_backlog	Close row in round (set end time)
EndTransactionPosda	commit\n	{}	{}	{NotInteractive,Backlog,Transaction,used_in_file_import_into_posda}	posda_files	End a transaction in Posda files
GetPosdaFileIdByDigest	select\n file_id\nfrom\n  file\nwhere\n  digest = ?\n\n	{digest}	{file_id}	{NotInteractive,Backlog,used_in_file_import_into_posda}	posda_files	Get posda file id of file by file_digest
InsertFileLocation	insert into file_location(\n  file_id, file_storage_root_id, rel_path\n) values ( ?, ?, ?)	{file_id,file_storage_root_id,rel_path}	{}	{NotInteractive,Backlog,Transaction,used_in_file_import_into_posda}	posda_files	Lock the file table in posda_files
MakePosdaFileReadyToProcess	update file\n  set ready_to_process = true\nwhere file_id = ?	{file_id}	{}	{NotInteractive,Backlog,used_in_file_import_into_posda}	posda_files	Lock the file table in posda_files
GetCurrentPosdaFileId	select  currval('file_file_id_seq') as id\n	{}	{file_id}	{NotInteractive,Backlog,used_in_file_import_into_posda}	posda_files	Get posda file id of created file row
RollbackPosda	rollback	{}	{}	{NotInteractive,Backlog,Transaction}	posda_files	Abort a transaction in Posda files
MarkFileAsInPosda	update request\nset\n  file_in_posda = true,\n  time_entered = now(),\n  posda_file_id = ?\nwhere\n  request_id = ?\n\n	{posda_file_id,request_id}	{}	{NotInteractive,Backlog}	posda_backlog	Update a request status to indicate file in Posda
InsertImportEvent	  insert into import_event(\n    import_type, import_time\n  ) values (\n    'Processing Backlog', ?\n  )	{time_tag}	{}	{NotInteractive,Backlog}	posda_files	Create an import_event
GetRoundId	select  currval('round_round_id_seq') as id\n	{}	{file_id}	{NotInteractive,Backlog}	posda_backlog	Get posda file id of created round row
InsertRoundCounts	insert into round_counts(\n  round_id, collection,\n  num_requests, priority\n) values (\n  ?, ?,\n  ?, ?\n)\n	{round_id,collection,num_requests,priority}	{}	{NotInteractive,Backlog}	posda_backlog	Insert a row into round_counts
CreateRound	insert into round(\n  round_created\n) values (\n  now()\n)\n	{}	{}	{NotInteractive,Backlog}	posda_backlog	Create a row in round table to record files_imported in this round
StartRound	update round\n  set round_start = now()\nwhere\n  round_id = ?\n	{round_id}	{}	{NotInteractive,Backlog}	posda_backlog	Close row in round (set end time)
AbortRound	update round\n  set round_aborted = now()\nwhere\n  round_id = ?\n	{round_id}	{}	{NotInteractive,Backlog}	posda_backlog	Close row in round (set end time)
AddWaitCount	update round\n  set wait_count = ?\nwhere\n  round_id = ?\n	{wait_count,round_id}	{}	{NotInteractive,Backlog}	posda_backlog	Set wait_count in round
AddProcessCount	update round\n  set process_count = ?\nwhere\n  round_id = ?\n	{process_count,round_id}	{}	{NotInteractive,Backlog}	posda_backlog	Set Process Count in round
PublicSeriesByCollection	select\n  p.patient_id as PID,\n  s.modality as Modality,\n  t.study_date as StudyDate,\n  t.study_desc as StudyDescription,\n  s.series_desc as SeriesDescription,\n  s.series_number as SeriesNumber,\n  t.study_instance_uid as StudyInstanceUID,\n  s.series_instance_uid as SeriesInstanceUID,\n  q.manufacturer as Mfr,\n  q.manufacturer_model_name as Model,\n  q.software_versions\nfrom\n  general_series s,\n  study t,\n  patient p,\n  trial_data_provenance tdp,\n  general_equipment q\nwhere\n  s.study_pk_id = t.study_pk_id and\n  s.general_equipment_pk_id = q.general_equipment_pk_id and\n  t.patient_pk_id = p.patient_pk_id and\n  p.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? \n	{collection}	{PID,Modality,StudyDate,StudyDescription,SeriesDescription,SeriesNumber,StudyInstanceUID,SeriesInstanceUID,Mfr,Model,software_versions}	{public}	public	List of all Series By Collection, Site on Public\n
GetPosdaFilesImportControl	select\n  status,\n  processor_pid,\n  idle_seconds,\n  pending_change_request,\n  files_per_round\nfrom\n  import_control	{}	{status,processor_pid,idle_seconds,pending_change_request,files_per_round}	{NotInteractive,PosdaImport}	posda_files	Get import control status from posda_files database
GoInServicePosdaImport	update import_control\nset status = 'service process running',\n  processor_pid = ?	{pid}	{}	{NotInteractive,PosdaImport}	posda_files	Claim control of posda_import
RelinquishControlPosdaImport	update import_control\nset status = 'idle',\n  processor_pid =  null,\n  pending_change_request = null	{}	{}	{NotInteractive,PosdaImport}	posda_files	relese control of posda_import
GetSsVolume	select \n  for_uid, study_instance_uid, series_instance_uid,\n  sop_class as sop_class_uid, sop_instance as sop_instance_uid\n  from ss_for natural join ss_volume where structure_set_id in (\n    select \n      structure_set_id \n    from\n      file_structure_set fs, file_sop_common sc\n    where\n      sc.file_id = fs.file_id and sop_instance_uid = ?\n)\n	{sop_instance_uid}	{for_uid,study_instance_uid,series_instance_uid,sop_class_uid,sop_instance_uid}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get Structure Set Volume\n\n
GetBacklogCountAndPrioritySummary	select\n  distinct collection, file_count as priority, count(*) as num_requests\nfrom\n  submitter natural join request natural join collection_count_per_round\nwhere\n  not file_in_posda\ngroup by collection, file_count\n	{}	{collection,priority,num_requests}	{NotInteractive,Backlog,backlog_status}	posda_backlog	Get List of Collections with Backlog and Priority Counts
RoundInfoById	select\n  round_id, collection,\n  round_created,\n  round_start,  \n  round_end,\n  round_aborted,\n  wait_count,\n  process_count,\n  num_entered,\n  num_failed,\n  num_dups,\n  num_requests,\n  priority\nfrom\n  round natural join round_counts natural join round_collection\nwhere round_id = ?\norder by round_id, collection	{round_id}	{round_id,collection,round_created,round_start,round_end,round_aborted,wait_count,process_count,num_entered,num_failed,num_dups,num_requests,priority}	{NotInteractive,Backlog,"Backlog Monitor"}	posda_backlog	Summary of round by id
RoundCountsByCollection	select \n  round_id, num_requests\nfrom round natural join round_counts\nwhere collection = ?	{collection}	{round_id,num_requests}	{NotInteractive,Backlog,"Backlog Monitor"}	posda_backlog	Summary of rounds
DatesOfUpload	select \n  distinct project_name as collection, site_name as site,\n  date_trunc as date, count(*) as num_uploads from (\n   select \n    project_name,\n    site_name,\n    date_trunc('day', import_time),\n    file_id\n  from file_import natural join import_event\n    natural join ctp_file \n) as foo\ngroup by project_name, site_name, date\norder by date, project_name, site_name	{}	{collection,site,date,num_uploads}	{receive_reports}	posda_files	Show me the dates with uploads for Collection from Site\n
RoundSummary2	select\n  round_id,\n  round_created,\n  round_start,  \n  round_end,\n  round_aborted,\n  wait_count,\n  process_count\nfrom\n  round\norder by round_id	{}	{round_id,round_created,round_start,round_end,round_aborted,wait_count,process_count}	{NotInteractive,Backlog,"Backlog Monitor"}	posda_backlog	Summary of rounds
RoundSummary1	select\n  distinct round_id,\n  round_start, \n  round_end - round_start as duration, \n  round_end, \n  sum(num_entered + num_dups),\n  ((round_end - round_start) / sum(num_entered + num_dups)) as sec_per_file\nfrom\n  round natural join round_collection\nwhere\n  round_end is not null \ngroup by \n  round_id, round_start, duration, round_end \norder by round_id	{}	{round_id,round_start,duration,round_end,sum,sec_per_file}	{NotInteractive,Backlog,"Backlog Monitor",backlog_analysis_reporting_tools}	posda_backlog	Summary of rounds
RoundCountsByCollection2	select\n  round_id, collection,\n  round_created,\n  round_start,  \n  round_end,\n  wait_count,\n  process_count,\n  num_entered,\n  num_failed,\n  num_dups,\n  num_requests,\n  priority\nfrom\n  round natural join round_counts natural join round_collection\nwhere collection = ?\norder by round_id, collection	{collection}	{round_id,collection,num_dups,round_created,round_start,round_end,wait_count,process_count,num_entered,num_failed,num_dups,num_requests,priority}	{NotInteractive,Backlog,"Backlog Monitor",backlog_analysis_reporting_tools}	posda_backlog	Summary of rounds
GetGeometricInfoIntake	select\n  sop_instance_uid, image_orientation_patient, image_position_patient,\n  pixel_spacing, i_rows, i_columns\nfrom\n  general_image\nwhere\n  sop_instance_uid = ?\n	{sop_instance_uid}	{sop_instance_uid,image_orientation_patient,image_position_patient,pixel_spacing,i_rows,i_columns}	{LinkageChecks,BySopInstance}	intake	Get Geometric Information by Sop Instance UID from intake
GetGeometricInfoPublic	select\n  sop_instance_uid, image_orientation_patient, image_position_patient,\n  pixel_spacing, i_rows, i_columns\nfrom\n  general_image\nwhere\n  sop_instance_uid = ?\n	{sop_instance_uid}	{sop_instance_uid,image_orientation_patient,image_position_patient,pixel_spacing,i_rows,i_columns}	{LinkageChecks,BySopInstance}	public	Get Geometric Information by Sop Instance UID from public
DupSopsWithConflictingPixels	select distinct sop_instance_uid, count\n  from (\n    select\n      distinct sop_instance_uid, count(*)\n    from (\n      select\n        sop_instance_uid, unique_pixel_data.digest as pixel_digest\n      from\n        file_sop_common natural join file natural join file_image join\n        image using (image_id) join unique_pixel_data using (unique_pixel_data_id)\n    )as foo group by sop_instance_uid\n  ) as foo where count > 1	{}	{sop_instance_uid,count}	{pix_data_dups}	posda_files	Find list of series with SOP with duplicate pixel data
GetGeometricInfo	select \n  distinct sop_instance_uid, iop as image_orientation_patient,\n  ipp as image_position_patient,\n  pixel_spacing,\n  pixel_rows as i_rows,\n  pixel_columns as i_columns\nfrom\n  file_sop_common join \n  file_patient using (file_id) join\n  file_image using (file_id) join \n  file_series using (file_id) join\n  file_study using (file_id) join\n  image using (image_id) join\n  file_image_geometry using (file_id) join\n  image_geometry using (image_geometry_id) \nwhere \n  sop_instance_uid = ?\n	{sop_instance_uid}	{sop_instance_uid,image_orientation_patient,image_position_patient,pixel_spacing,i_rows,i_columns}	{LinkageChecks,BySopInstance}	posda_files	Get Geometric Information by Sop Instance UID from posda
GetRoiList	select \n   roi_id, roi_num ,roi_name\nfrom \n  roi natural join structure_set natural join file_structure_set \n  join file_sop_common using(file_id)\nwhere\n  sop_instance_uid = ?\n	{sop_instance_uid}	{roi_id,roi_num,roi_name}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get List of ROI's in a structure Set\n\n
SeriesWithDupSopsWithConflictingPixels	select \n  distinct project_name, site_name, patient_id, study_instance_uid, \n  series_instance_uid, count(distinct file_id)\nfrom\n  ctp_file natural join file_sop_common natural join file_patient natural join \n  file_study natural join file_series \nwhere sop_instance_uid in (\n  select distinct sop_instance_uid\n  from (\n    select\n      distinct sop_instance_uid, count(*)\n    from (\n      select\n        sop_instance_uid, unique_pixel_data.digest as pixel_digest\n      from\n        file_sop_common natural join file natural join file_image join\n        image using (image_id) join unique_pixel_data using (unique_pixel_data_id)\n    )as foo group by sop_instance_uid\n  ) as foo where count > 1\n)\ngroup by\n  project_name, site_name, patient_id, study_instance_uid, series_instance_uid\norder by \n  project_name, site_name, patient_id, count desc\n  	{}	{project_name,site_name,patient_id,study_instance_uid,series_instance_uid,count}	{pix_data_dups}	posda_files	Find list of series with SOP with duplicate pixel data
SeriesWithDupSops	select\n  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, count(*)\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    study_instance_uid, series_instance_uid,\n    file_id\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_study natural join file_series\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid from (\n        select distinct sop_instance_uid, count(*) from (\n          select distinct file_id, sop_instance_uid \n          from\n            ctp_file natural join file_sop_common\n            natural join file_patient\n          where\n            visibility is null\n        ) as foo group by sop_instance_uid order by count desc\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\ngroup by collection, site, subj_id, study_instance_uid, series_instance_uid\n	{}	{collection,site,subj_id,count,study_instance_uid,series_instance_uid}	{duplicates}	posda_files	Return a count of duplicate SOP Instance UIDs\n
SubjectsWithDupSopsWithConflictingPixels	select \n  distinct project_name, site_name, patient_id, count(distinct file_id)\nfrom\n  ctp_file natural join file_sop_common natural join file_patient\nwhere sop_instance_uid in (\n  select distinct sop_instance_uid\n  from (\n    select\n      distinct sop_instance_uid, count(*)\n    from (\n      select\n        sop_instance_uid, unique_pixel_data.digest as pixel_digest\n      from\n        file_sop_common natural join file natural join file_image join\n        image using (image_id) join unique_pixel_data using (unique_pixel_data_id)\n    )as foo group by sop_instance_uid\n  ) as foo where count > 1\n)\ngroup by\n  project_name, site_name, patient_id\norder by \n  project_name, site_name, patient_id, count desc\n  	{}	{project_name,site_name,patient_id,count}	{pix_data_dups}	posda_files	Find list of series with SOP with duplicate pixel data
GetPlansAndSSReferences	select sop_instance_uid as plan_referencing,\nss_referenced_from_plan as ss_referenced\nfrom plan natural join file_plan join file_sop_common using(file_id)	{}	{plan_referencing,ss_referenced}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get list of plan and ss sops where plan references ss\n\n
SubjectsWithDupSopsWithStudySeries	select \n  distinct project_name, site_name, patient_id, count(distinct file_id)\nfrom\n  ctp_file natural join file_sop_common natural join file_patient\nwhere sop_instance_uid in (\n  select distinct sop_instance_uid\n  from (\n    select\n      distinct sop_instance_uid, count(*)\n    from (\n      select\n        sop_instance_uid, study_instance_uid, series_instance_uid\n      from\n        file_sop_common natural join file_series natural join file_study\n    )as foo group by sop_instance_uid\n  ) as foo where count > 1\n)\ngroup by\n  project_name, site_name, patient_id\norder by \n  project_name, site_name, patient_id, count desc\n  	{}	{project_name,site_name,patient_id,count}	{pix_data_dups}	posda_files	Find list of series with SOP with conflicting study or series
GetRoiCounts	select \n   distinct sop_instance_uid, count(distinct roi_id)\nfrom \n  roi natural join structure_set natural join file_structure_set \n  join file_sop_common using(file_id)\ngroup by sop_instance_uid\norder by count desc\n	{}	{sop_instance_uid,count}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get List of ROI's in a structure Set\n\n
GetContoursFromRoiId	select\n  roi_contour_id, contour_num, geometric_type, \n  number_of_points, sop_class as linked_image_sop_class,\n  sop_instance as linked_image_sop_instance, \n  frame_number as linked_image_frame_number\nfrom\n  roi_contour natural left join contour_image\nwhere roi_id = ?	{roi_id}	{roi_contour_id,contour_num,geometric_type,number_of_points,linked_image_sop_class,linked_image_sop_instance,linked_image_frame_number}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get List of ROI's in a structure Set\n\n
GetContourData	select\n  contour_data\nfrom\n  roi_contour\nwhere roi_contour_id = ?	{roi_contour_id}	{contour_data}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get Contour Data by roi_contour_id\n
GetRoiCountsBySeriesInstanceUid	select \n   distinct sop_instance_uid, count(distinct roi_id)\nfrom \n  roi natural join structure_set natural join file_structure_set \n  join file_sop_common using(file_id)\nwhere sop_instance_uid in (\n  select distinct sop_instance_uid from file_sop_common natural join file_series\n  where series_instance_uid = ?\n)\ngroup by sop_instance_uid\norder by count desc\n	{series_instance_uid}	{sop_instance_uid,count}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get List of ROI's in a structure Set\n\n
GetCountSsVolume	select count(distinct sop_instance_uid) as num_links from \n(select \n  for_uid, study_instance_uid, series_instance_uid,\n  sop_class as sop_class_uid, sop_instance as sop_instance_uid\n  from ss_for natural join ss_volume where structure_set_id in (\n    select \n      structure_set_id \n    from\n      file_structure_set fs, file_sop_common sc\n    where\n      sc.file_id = fs.file_id and sop_instance_uid = ?\n)\n) as foo;	{sop_instance_uid}	{num_links}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get Structure Set Volume\n\n
GetSeriesFileCountsByPatientId	select\n  series_instance_uid, modality, dicom_file_type, count(distinct sop_instance_uid) as num_sops\nfrom\n  file_series natural join file_patient natural join \n  dicom_file natural join file_sop_common\nwhere\n  patient_id = ?\ngroup by series_instance_uid, modality, dicom_file_type\n	{patient_id}	{series_instance_uid,modality,dicom_file_type,num_sops}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get Counts in file_series by patient_id\n\n
UpdPosdaPhiSimplePrivDisp	update\n  element_seen\nset\n  private_disposition = ?\nwhere\n  element_sig_pattern = ? and\n  vr = ?\n\n	{private_disposition,element_signature,vr}	{}	{NotInteractive,used_in_reconcile_tag_names}	posda_phi_simple	Update name_chain in element_seen
GetCountSsVolumeBySeriesUid	select\n  distinct sop_instance_uid, count(distinct sop_instance_link) as num_links \nfrom (\n  select \n    sop_instance_uid, for_uid, study_instance_uid, series_instance_uid,\n    sop_class as sop_class_uid, sop_instance as sop_instance_link\n  from\n    ss_for natural join ss_volume natural join\n    file_structure_set join file_sop_common using (file_id)\n  where structure_set_id in (\n    select \n      structure_set_id \n    from\n      file_structure_set fs, file_sop_common sc\n    where\n      sc.file_id = fs.file_id and sop_instance_uid in (\n         select distinct sop_instance_uid from file_sop_common natural join file_series\n         where series_instance_uid = ?\n     )\n  )\n) as foo \ngroup by sop_instance_uid	{series_instance_uid}	{sop_instance_uid,num_links}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get Structure Set Volume\n\n
GetListCollectionPrios	select collection, file_count as priority\nfrom collection_count_per_round\norder by collection\n\n	{}	{collection,priority}	{NotInteractive,Backlog,"Backlog Monitor",backlog_status}	posda_backlog	Get a list of all collections in backlog with defined counts
RoundSummary1Recent	select\n  distinct round_id,\n  round_start, \n  round_end - round_start as duration, \n  round_end, \n  sum(num_entered + num_dups),\n  ((round_end - round_start) / sum(num_entered + num_dups)) as sec_per_file\nfrom\n  round natural join round_collection\nwhere\n  round_end is not null and (now() - round_end) < '24:00'\ngroup by \n  round_id, round_start, duration, round_end \norder by round_id	{}	{round_id,round_start,duration,round_end,sum,sec_per_file}	{NotInteractive,Backlog,"Backlog Monitor",backlog_status}	posda_backlog	Summary of rounds
HideFile	update\n  ctp_file\nset\n  visibility = 'hidden'\nwhere\n  file_id = ?\n	{file_id}	{}	{ImageEdit,NotInteractive}	posda_files	Hide a file\n
GetVisibilityByFileId	select\n  file_id, visibility\nfrom\n   ctp_file\nwhere\n   file_id = ?\n	{file_id}	{file_id,visibility}	{ImageEdit,NotInteractive}	posda_files	Get Visibility for a file by file_id\n
RoundRunningTimeCurrentRound	select now() - round_start as running_time from round where round_id in (\nselect round_id from round where round_end is null and round_start is not null)	{}	{running_time}	{NotInteractive,Backlog,"Backlog Monitor",backlog_status}	posda_backlog	Summary of round by id
tags_by_role	select\n  filter_name as role, unnest(tags_enabled) as tag\nfrom query_tag_filter where filter_name = ?	{role}	{role,tag}	{roles}	posda_queries	Show a complete list of associated tags for a role\n
GetCountSsVolumeByPatientId	select\n  distinct sop_instance_uid, count(distinct sop_instance_link) as num_links \nfrom (\n  select \n    sop_instance_uid, for_uid, study_instance_uid, series_instance_uid,\n    sop_class as sop_class_uid, sop_instance as sop_instance_link\n  from\n    ss_for natural join ss_volume natural join\n    file_structure_set join file_sop_common using (file_id)\n  where structure_set_id in (\n    select \n      structure_set_id \n    from\n      file_structure_set fs, file_sop_common sc\n    where\n      sc.file_id = fs.file_id and sop_instance_uid in (\n         select distinct sop_instance_uid \n         from file_sop_common natural join file_patient\n         where patient_id = ?\n     )\n  )\n) as foo \ngroup by sop_instance_uid	{patient_id}	{sop_instance_uid,num_links}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get Structure Set Volume\n\n
WhereSopSits	select distinct\n  project_name as collection,\n  site_name as site,\n  patient_id,\n  study_instance_uid,\n  series_instance_uid,\n  sop_instance_uid\nfrom\n  file_patient natural join\n  file_study natural join\n  file_series natural join\n  file_sop_common natural join\n  ctp_file\nwhere file_id in (\n  select\n    distinct file_id\n  from\n    file_sop_common natural join ctp_file\n  where\n    sop_instance_uid = ? and visibility is null\n)\n	{sop_instance_uid}	{collection,site,patient_id,study_instance_uid,series_instance_uid}	{posda_files,sops,BySopInstance}	posda_files	Get Collection, Site, Patient, Study Hierarchy in which SOP resides\n
CountsByCollectionDateRange	select\n  distinct\n    patient_id, image_type, modality, study_date, study_description,\n    series_description, study_instance_uid, series_instance_uid,\n    manufacturer, manuf_model_name, software_versions,\n    count(distinct sop_instance_uid) as num_sops,\n    count(distinct file_id) as num_files,\n    min(import_time) as earliest,\n    max(import_time) as latest\nfrom\n  ctp_file join file_patient using(file_id)\n  join file_series using(file_id)\n  join file_sop_common using(file_id)\n  join file_study using(file_id)\n  join file_equipment using(file_id)\n  join file_import using(file_id)\n  join import_event using(import_event_id)\n  left join file_image using(file_id)\n  left join image using (image_id)\nwhere\n  project_name = ? and visibility is null\n  and import_time > ? and import_time < ?\ngroup by\n  patient_id, image_type, modality, study_date, study_description,\n  series_description, study_instance_uid, series_instance_uid,\n  manufacturer, manuf_model_name, software_versions\norder by\n  patient_id, study_instance_uid, series_instance_uid, image_type,\n  modality, study_date, study_description,\n  series_description,\n  manufacturer, manuf_model_name, software_versions\n	{collection,from,to}	{patient_id,image_type,modality,study_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files,earliest,latest}	{counts,count_queries}	posda_files	Counts query by Collection, Site\n
UpdateNameChain	update element_signature set \n  name_chain = ?\nwhere\n  element_signature = ? and\n  vr = ?\n	{name_chain,element_signature,vr}	{}	{NotInteractive,Update,ElementDisposition}	posda_phi	Update Element Disposition\nFor use in scripts\nNot really intended for interactive use\n
WhereSopSitsPublic	select distinct\n  tdp.project as collection,\n  tdp.dp_site_name as site,\n  p.patient_id,\n  i.study_instance_uid,\n  i.series_instance_uid\nfrom\n  general_image i,\n  patient p,\n  trial_data_provenance tdp\nwhere\n  sop_instance_uid = ?\n  and i.patient_pk_id = p.patient_pk_id\n  and i.trial_dp_pk_id = tdp.trial_dp_pk_id\n	{sop_instance_uid}	{collection,site,patient_id,study_instance_uid,series_instance_uid}	{posda_files,sops,BySopInstance}	public	Get Collection, Patient, Study Hierarchy in which SOP resides\n
WhereSopSitsPrivate	select distinct\n  tdp.project as collection,\n  tdp.dp_site_name as site,\n  p.patient_id,\n  i.study_instance_uid,\n  i.series_instance_uid\nfrom\n  general_image i,\n  patient p,\n  trial_data_provenance tdp\nwhere\n  sop_instance_uid = ?\n  and i.patient_pk_id = p.patient_pk_id\n  and i.trial_dp_pk_id = tdp.trial_dp_pk_id\n	{sop_instance_uid}	{collection,site,patient_id,study_instance_uid,series_instance_uid}	{posda_files,sops,BySopInstance}	private	Get Collection, Patient, Study Hierarchy in which SOP resides\n
ListOfElementSignaturesAndVrs	select\n  distinct element_signature, vr, name_chain, count(*)\nfrom\n  element_signature\ngroup by element_signature, vr, name_chain\n	{}	{element_signature,vr,name_chain,count}	{NotInteractive,Update,ElementDisposition}	posda_phi	Get Disposition of element by sig and VR
DistinctSeriesBySubjectPublic	select\n  distinct s.series_instance_uid, modality, count(*) as num_images\nfrom\n  general_image i, general_series s,\n  trial_data_provenance tdp\nwhere\n  s.general_series_pk_id = i.general_series_pk_id and\n  i.patient_id = ? and i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ?\ngroup by series_instance_uid, modality\n	{subject_id,project_name}	{series_instance_uid,modality,num_images}	{by_subject,find_series,public}	public	Get Series in A Collection, Site, Subject\n
SimplePhiScanStatusInProcess	select\n  phi_scan_instance_id as id,\n  start_time,\n  now() - start_time as duration,\n  description,\n  num_series as to_scan,\n  num_series_scanned as scanned,\n  (((now() - start_time) / num_series_scanned) * (num_series -\n  num_series_scanned)) + now() as projected_completion,\n  (cast(num_series_scanned as float) / \n    cast(num_series as float)) * 100.0 as percentage,\n  file_query\nfrom\n  phi_scan_instance\nwhere\n   num_series > num_series_scanned\n   and num_series_scanned > 0\norder by id\n	{}	{id,description,start_time,duration,to_scan,scanned,percentage,projected_completion,file_query}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
DistinctSeriesByCollectionSite	select distinct series_instance_uid, dicom_file_type, modality, count(*)\nfrom (\nselect distinct series_instance_uid, sop_instance_uid, dicom_file_type, modality from (\nselect\n   distinct series_instance_uid, modality, sop_instance_uid,\n   file_id, dicom_file_type\n from file_series natural join file_sop_common\n   natural join ctp_file natural join dicom_file\nwhere\n  project_name = ? and site_name = ?\n  and visibility is null)\nas foo\ngroup by series_instance_uid, sop_instance_uid, dicom_file_type, modality)\nas foo\ngroup by series_instance_uid, dicom_file_type, modality\n	{project_name,site_name}	{series_instance_uid,dicom_file_type,modality,count}	{by_collection,find_series,compare_collection_site,search_series,edit_files,simple_phi}	posda_files	Get Series in A Collection, site with dicom_file_type, modality, and sop_count\n
GetReferencedButUnknownSsSops	select\n  sop_instance_uid, \n  ss_referenced_from_plan as ss_sop_instance_uid \nfrom \n  plan p natural join file_plan join file_sop_common using(file_id)\nwhere\n  not exists (\n  select\n    sop_instance_uid \n  from\n    file_sop_common fsc\n  where\n    p.ss_referenced_from_plan  = fsc.sop_instance_uid\n)	{}	{sop_instance_uid,ss_sop_instance_uid}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get list of plan which reference unknown SOPs\n\n
GetDosesAndPlanReferences	select\n  sop_instance_uid as dose_referencing,\n  rt_dose_referenced_plan_uid as plan_referenced\nfrom\n  rt_dose natural join file_dose join file_sop_common using (file_id)	{}	{dose_referencing,plan_referenced}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get list of dose and plan sops where dose references plan\n
GetDosesReferencingBadPlans	select\n  sop_instance_uid\nfrom\n  file_sop_common\nwhere file_id in (\n  select \n    file_id\n  from\n    rt_dose d natural join file_dose  \n  where\n    not exists (\n      select\n        sop_instance_uid \n      from\n        file_sop_common fsc \n      where d.rt_dose_referenced_plan_uid = fsc.sop_instance_uid\n  )\n)	{}	{sop_instance_uid}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get list of plan which reference unknown SOPs\n\n
GetReferencedButUnknownPlanSops	select\n  sop_instance_uid, \n  rt_dose_referenced_plan_uid as plan_sop_instance_uid \nfrom \n  rt_dose d natural join file_dose join file_sop_common using(file_id)\nwhere\n  not exists (\n  select\n    sop_instance_uid \n  from\n    file_sop_common fsc\n  where\n    d.rt_dose_referenced_plan_uid = fsc.sop_instance_uid\n)	{}	{sop_instance_uid,plan_sop_instance_uid}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get list of doses which reference unknown SOPs\n\n
GetBacklogControl	select\n  status, processor_pid,\n  idle_poll_interval,\n  last_service, pending_change_request,\n  source_pending_change_request,\n  request_time, num_files_per_round,\n  target_queue_size,\n  (now() - request_time) as time_pending\nfrom control_status\n	{}	{status,processor_pid,idle_poll_interval,last_service,pending_change_request,source_pending_change_request,request_time,num_files_per_round,target_queue_size,time_pending}	{NotInteractive,Backlog,"Backlog Monitor"}	posda_backlog	Get control status from backlog database
GetPlansReferencingBadSS	select\n  project_name as collection,\n  site_name as site,\n  patient_id,\n  sop_instance_uid\nfrom\n  file_sop_common natural join\n  file_patient natural join ctp_file\nwhere\n  project_name = ? and\n  visibility is null and\n  file_id in (\nselect file_id from plan p natural join file_plan  where\nnot exists (select sop_instance_uid from file_sop_common fsc where p.ss_referenced_from_plan \n= fsc.sop_instance_uid))	{collection}	{collection,site,patient_id,sop_instance_uid}	{"Structure Sets",sops,LinkageChecks,plan_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
GetEditList	select * from dicom_edit_event	{}	{dicom_edit_event_id,from_dicom_file,to_dicom_file,edit_desc_file,when_done,performing_user}	{ImageEdit}	posda_files	Get list of dicom_edit_event
RequestShutdown	update control_status\n  set pending_change_request = 'shutdown',\n  source_pending_change_request = 'DbIf',\n  request_time = now()	{}	{}	{NotInteractive,Backlog,"Backlog Monitor"}	posda_backlog	request a shutdown of Backlog processing
ListOfCollectionsAndSitesLikeCollection	select \n    distinct project_name, site_name, count(*) \nfrom \n   ctp_file natural join file_study natural join\n   file_series\nwhere\n  visibility is null and project_name like ?\ngroup by project_name, site_name\norder by project_name, site_name\n	{CollectionLike}	{project_name,site_name,count}	{AllCollections,universal}	posda_files	Get a list of collections and sites\n
DupReport	select\n  distinct collection,\n  sum(num_entered) num_files,\n  sum(num_dups) num_dups,\n  (cast(sum(num_dups) as float)/cast((sum(num_entered) + sum(num_dups)) as float))*100.0 as\n   percent_dups\nfrom\n  round_collection\ngroup by collection\norder by percent_dups desc	{}	{collection,num_files,num_dups,percent_dups}	{Backlog,"Backlog Monitor",backlog_analysis_reporting_tools}	posda_backlog	Report on Percentage of duplicates by collection
DiskSpaceByCollectionSummaryWithDups	select\n  distinct project_name as collection, sum(size) as total_bytes\nfrom\n  ctp_file natural join file natural join file_import\nwhere\n  file_id in (\n  select distinct file_id\n  from ctp_file\n  )\ngroup by project_name\norder by total_bytes\n	{}	{collection,total_bytes}	{by_collection,posda_files,storage_used,summary}	posda_files	Get disk space used for all collections\n
insert_list_of_roles	update query_tag_filter\nset tags_enabled = ?\nwhere filter_name = ?	{tag_list,role}	{}	{roles}	posda_queries	Insert a list of tags for a role\n
RoundSummary1VeryRecent	select\n  distinct round_id,\n  round_start, \n  round_end - round_start as duration, \n  round_end, \n  sum(num_entered + num_dups),\n  ((round_end - round_start) / sum(num_entered + num_dups)) as sec_per_file\nfrom\n  round natural join round_collection\nwhere\n  round_end is not null and (now() - round_end) < '1:00'\ngroup by \n  round_id, round_start, duration, round_end \norder by round_id	{}	{round_id,round_start,duration,round_end,sum,sec_per_file}	{NotInteractive,Backlog,"Backlog Monitor",backlog_status}	posda_backlog	Summary of rounds
ListOfCollectionsBySite	select \n    distinct project_name as collection, site_name, count(*) \nfrom \n   ctp_file natural join file_study natural join\n   file_series\nwhere\n  visibility is null and site_name = ?\ngroup by project_name, site_name\norder by project_name, site_name\n	{site}	{collection,site_name,count}	{AllCollections,universal}	posda_files	Get a list of collections and sites\n
FindInconsistentSeriesByCollectionSite	select series_instance_uid from (\nselect distinct series_instance_uid, count(*) from (\n  select distinct\n    series_instance_uid, modality, series_number, laterality, series_date,\n    series_time, performing_phys, protocol_name, series_description,\n    operators_name, body_part_examined, patient_position,\n    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n    performed_procedure_step_start_date, performed_procedure_step_start_time,\n    performed_procedure_step_desc, performed_procedure_step_comments,\n    count(*)\n  from\n    file_series natural join ctp_file\n  where\n    project_name = ? and site_name = ? and visibility is null\n  group by\n    series_instance_uid, modality, series_number, laterality, series_date,\n    series_time, performing_phys, protocol_name, series_description,\n    operators_name, body_part_examined, patient_position,\n    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n    performed_procedure_step_start_date, performed_procedure_step_start_time,\n    performed_procedure_step_desc, performed_procedure_step_comments\n) as foo\ngroup by series_instance_uid\n) as foo\nwhere count > 1\n	{collection,site}	{series_instance_uid}	{consistency,find_series}	posda_files	Find Inconsistent Series\n
GetPatientStatus	select\n  patient_import_status as status\nfrom\n  patient_import_status\nwhere\n  patient_id = ?\n	{patient_id}	{status}	{NotInteractive,PatientStatus,Update}	posda_files	Get Patient Status
FilesInSeriesWithPositionPixelDig	select\n  distinct file_id, image_id, unique_pixel_data_id, ipp, instance_number\nfrom\n  file_series natural join file_image natural join ctp_file natural join file_sop_common\n  natural join image natural join image_geometry\nwhere\n  series_instance_uid = ? and visibility is null\n	{series_instance_uid}	{file_id,image_id,unique_pixel_data_id,ipp,instance_number}	{SeriesSendEvent,by_series,find_files,for_send}	posda_files	Get file info from series for comparison of dup_series
IntakePatientStudySeriesHierarchyByCollectionSite	select\n  p.patient_id as patient_id,\n  t.study_instance_uid as study_instance_uid,\n  s.series_instance_uid as series_instance_uid\nfrom\n  general_series s,\n  study t,\n  patient p,\n  trial_data_provenance tdp\nwhere\n  s.study_pk_id = t.study_pk_id and\n  t.patient_pk_id = p.patient_pk_id and\n  p.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and\n  tdp.dp_site_name = ?\n	{collection,site}	{patient_id,study_instance_uid,series_instance_uid}	{intake,Hierarchy}	intake	Patient, study, series hierarchy by Collection, Site on Intake\n
ListOfRepeatingPrivateElementsFromDD	select\n  ptrg_signature_masked as tag,\n  ptrg_base_grp as base_grp,\n  ptrg_grp_mask as id_mask,\n  ptrg_grp_ext_mask as ext_mask,\n  ptrg_grp_ext_shift as ext_shift,\n  ptrg_consensus_vr as vr,\n  ptrg_consensus_vm as vm,\n  ptrg_consensus_name as name \nfrom ptrg	{}	{tag,base_grp,id_mask,ext_mask,ext_shift,vr,vm,name}	{ElementDisposition}	posda_private_tag	Get List of Repeating Private Tags from DD
PatientStatusChange	select\n  patient_id, old_pat_status as from,\n  new_pat_status as to, pat_stat_change_who as by,\n  pat_stat_change_why as why,\n  when_pat_stat_changed as when\nfrom patient_import_status_change\nwhere patient_id in(\n  select distinct patient_id\n  from file_patient natural join ctp_file\n  where visibility is null\n)\norder by patient_id, when_pat_stat_changed\n	{}	{patient_id,from,to,by,why,when}	{PatientStatus}	posda_files	Get History of Patient Status Changes by Collection\n
GetPublicHierarchyBySopInstance	select\n  i.patient_id, s.study_instance_uid, s.series_instance_uid, modality, sop_instance_uid\nfrom \n  general_image i, general_series s where sop_instance_uid = ? and\n  s.general_series_pk_id = i.general_series_pk_id	{sop_instance_uid}	{patient_id,study_instance_uid,series_instance_uid,modality,sop_instance_uid}	{Hierarchy}	public	Get Patient, Study, Series, Modality, Sop Instance by sop_instance from public database
ListOfPrivateElementsFromDD	select\n  pt_signature as tag,\n  pt_consensus_vr as vr,\n  pt_consensus_vm as vm,\n  pt_consensus_name as name\nfrom\n  pt	{}	{tag,vr,vm,name}	{ElementDisposition}	posda_private_tag	Get List of Private Tags from DD
FilesInSeriesForApplicationOfPrivateDispositionIntake	select\n  i.dicom_file_uri as path, i.sop_instance_uid, s.modality\nfrom\n  general_image i, general_series s\nwhere\n  i.general_series_pk_id = s.general_series_pk_id and\n  s.series_instance_uid = ?	{series_instance_uid}	{path,sop_instance_uid,modality}	{find_files,ApplyDisposition,intake}	intake	Get path, sop_instance_uid, and modality for all files in a series\n
InsertVisibilityChange	insert into file_visibility_change(\n  file_id, user_name, time_of_change,\n  prior_visibility, new_visibility, reason_for\n)values(\n  ?, ?, now(),\n  ?, ?, ?\n)\n	{file_id,user_name,prior_visibility,new_visibility,reason}	{}	{ImageEdit,NotInteractive}	posda_files	Insert Image Visibility Change\n\n
SubjectsWithDuplicateSopsWithConflictingGeometricInfo	select distinct patient_id, study_instance_uid, series_instance_uid, count(*)\nfrom\n  file_patient natural join file_sop_common natural join file_series natural join file_study\nwhere sop_instance_uid in (\n  select sop_instance_uid from (\n    select distinct sop_instance_uid, count(*) from (\n    select \n      distinct sop_instance_uid, iop as image_orientation_patient,\n      ipp as image_position_patient,\n      pixel_spacing,\n      pixel_rows as i_rows,\n      pixel_columns as i_columns\n    from\n      file_sop_common join \n      file_patient using (file_id) join\n      file_image using (file_id) join \n      file_series using (file_id) join\n      file_study using (file_id) join\n      image using (image_id) join\n      file_image_geometry using (file_id) join\n      image_geometry using (image_geometry_id) \n    ) as foo \n    group by sop_instance_uid\n  ) as foo where count > 1\n) group by patient_id, study_instance_uid, series_instance_uid	{}	{patient_id,study_instance_uid,series_instance_uid,count}	{duplicates}	posda_files	Return a count of duplicate SOP Instance UIDs with conflicting Geometric Information by Patient Id, study, series\n
PixelTypesWithSOP	select\n  distinct photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  coalesce(number_of_frames,1) > 1 as is_multi_frame,\n  pixel_representation,\n  planar_configuration,\n  modality,\n  dicom_file_type,\n  count(*)\nfrom\n  image natural join file_image natural join file_series natural join dicom_file\ngroup by\n  photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  is_multi_frame,\n  pixel_representation,\n  planar_configuration,\n  modality,\n  dicom_file_type\norder by\n  count desc	{}	{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,is_multi_frame,pixel_representation,planar_configuration,modality,dicom_file_type,count}	{all,find_pixel_types,posda_files}	posda_files	Get distinct pixel types\n
GetBacklogQueueSize	select\n count(*) as num_files\nfrom\n  request\nwhere\n  file_in_posda is false \n\n	{}	{num_files}	{NotInteractive,Backlog,"Backlog Monitor",backlog_status}	posda_backlog	Get size of queue  in PosdaBacklog
CountsByCollectionSiteExt	select\n  distinct\n    patient_id, image_type, dicom_file_type, modality, study_date, study_description,\n    series_description, study_instance_uid, series_instance_uid,\n    manufacturer, manuf_model_name, software_versions,\n    count(distinct sop_instance_uid) as num_sops,\n    count(distinct file_id) as num_files\nfrom\n  ctp_file join file_patient using(file_id)\n  join dicom_file using(file_id)\n  join file_series using(file_id)\n  join file_sop_common using(file_id)\n  join file_study using(file_id)\n  join file_equipment using(file_id)\n  left join file_image using(file_id)\n  left join image using (image_id)\nwhere\n  project_name = ? and site_name = ? and visibility is null\ngroup by\n  patient_id, image_type, dicom_file_type, modality, study_date, study_description,\n  series_description, study_instance_uid, series_instance_uid,\n  manufacturer, manuf_model_name, software_versions\norder by\n  patient_id, study_instance_uid, series_instance_uid, image_type, dicom_file_type,\n  modality, study_date, study_description,\n  series_description,\n  manufacturer, manuf_model_name, software_versions\n	{collection,site}	{patient_id,image_type,dicom_file_type,modality,study_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files}	{counts}	posda_files	Counts query by Collection, Site\n
GetListStructureSets	select \n  distinct project_name, site_name, patient_id, sop_instance_uid\nfrom\n  file_sop_common natural join ctp_file natural join dicom_file natural join file_patient\nwhere\n  dicom_file_type = 'RT Structure Set Storage' and visibility is null\norder by project_name, site_name, patient_id	{}	{project_name,patient_id,site_name,sop_instance_uid}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get Structure Set List\n\n
GetListStructureSetsByCollectionSite	select \n  distinct project_name, site_name, patient_id, sop_instance_uid\nfrom\n  file_sop_common natural join ctp_file natural join dicom_file natural join file_patient\nwhere\n  dicom_file_type = 'RT Structure Set Storage' and visibility is null\n  and project_name = ? and site_name = ?\norder by project_name, site_name, patient_id	{collection,site}	{project_name,patient_id,site_name,sop_instance_uid}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get Structure Set List\n\n
RoundInfoLastCompleteRound	select\n  round_id, collection,\n  round_created,\n  round_start,  \n  round_end,\n  round_aborted,\n  wait_count,\n  process_count,\n  num_entered,\n  num_failed,\n  num_dups,\n  num_requests,\n  priority\nfrom\n  round natural join round_counts natural join round_collection\nwhere round_id in (\n  select max(round_id) as round_id from round where round_end is not null\n)\norder by round_id, collection	{}	{round_id,collection,round_created,round_start,round_end,round_aborted,wait_count,process_count,num_entered,num_failed,num_dups,num_requests,priority}	{NotInteractive,Backlog,"Backlog Monitor",backlog_status}	posda_backlog	Summary of round by id
GetBacklogQueueSizeWithCollection	select\n distinct collection, count(*) as num_files\nfrom\n  request natural join submitter\nwhere\n  file_in_posda is false\ngroup by collection\n\n	{}	{collection,num_files}	{NotInteractive,Backlog,"Backlog Monitor",backlog_status}	posda_backlog	Get size of queue  in PosdaBacklog
RoundCountsByCollection2Recent	select\n  round_id, collection,\n  round_created,\n  round_start - round_created as q_time,  \n  round_end - round_created as duration,\n  wait_count,\n  process_count,\n  num_entered,\n  num_failed,\n  num_dups,\n  num_requests,\n  priority\nfrom\n  round natural join round_counts natural join round_collection\nwhere collection = ? and (now() - round_end) < '1:00'\norder by round_id, collection	{collection}	{round_id,collection,round_created,q_time,duration,wait_count,process_count,num_entered,num_failed,num_dups,num_requests,priority}	{NotInteractive,Backlog,"Backlog Monitor",backlog_status}	posda_backlog	Summary of rounds
RoundCountsByCollection2DateRange	select\n  round_id, collection,\n  round_created,\n  round_start,  \n  round_end - round_start as duration,\n  wait_count,\n  process_count,\n  num_entered,\n  num_failed,\n  num_dups,\n  num_requests,\n  priority\nfrom\n  round natural join round_counts natural join round_collection\nwhere collection = ? and round_start > ? and round_end < ?\norder by round_id, collection	{collection,from,to}	{round_id,collection,num_dups,round_created,round_start,duration,wait_count,process_count,num_entered,num_failed,num_dups,num_requests,priority}	{NotInteractive,Backlog,"Backlog Monitor",backlog_analysis_reporting_tools}	posda_backlog	Summary of rounds
list_of_roles	select\n  filter_name as role\nfrom query_tag_filter	{}	{role}	{roles}	posda_queries	Show a complete list of roles\n
PatientStudySeriesHierarchyByCollectionSiteMatchingSeriesDesc	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid\nfrom\n  file_study natural join ctp_file natural join file_series natural join file_patient\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file natural join file_series\n    where project_name = ? and site_name = ? \n    and visibility is null and series_description like ?\n  )\norder by patient_id, study_instance_uid, series_instance_uid	{collection,site,series_descriptions_matching}	{patient_id,study_instance_uid,series_instance_uid}	{Hierarchy}	posda_files	Construct list of series in a collection in a Patient, Study, Series Hierarchy excluding matching SeriesDescriptons
PatientStudySeriesFileHierarchyByCollectionSiteExt	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid,\n  dicom_file_type,\n  modality,\n  count(*)\nfrom\n  file_study natural join\n  dicom_file natural join\n  ctp_file natural join\n  file_series natural join \n  file_patient natural join\n  file_sop_common\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file\n    where project_name = ? and site_name = ? and visibility is null\n  )\ngroup by\n  patient_id,\n  study_instance_uid,\n  series_instance_uid,\n  dicom_file_type,\n  modality\norder by patient_id, study_instance_uid, series_instance_uid	{collection,site}	{patient_id,study_instance_uid,series_instance_uid,dicom_file_type,modality,count}	{Hierarchy}	posda_files	Construct list of files in a collection, site in a Patient, Study, Series, with Modality of file
ReviewEditsBySite	select\n  distinct project_name,\n  site_name,\n  series_instance_uid, \n  new_visibility, \n  reason_for,\n  min(time_of_change) as earliest,\n  max(time_of_change) as latest,\n  count(*) as num_files\nfrom\n  file_visibility_change natural join\n  ctp_file natural join\n  file_series\nwhere \n  site_name = ?\ngroup by \n  project_name, site_name, series_instance_uid, new_visibility, reason_for	{site}	{project_name,site_name,series_instance_uid,new_visibility,reason_for,earliest,latest,num_files}	{Hierarchy,review_visibility_changes}	posda_files	Show all file visibility changes by series for site
ReviewEditsByCollectionSite	select\n  distinct project_name,\n  site_name,\n  series_instance_uid, \n  new_visibility, \n  reason_for,\n  min(time_of_change) as earliest,\n  max(time_of_change) as latest,\n  count(*) as num_files\nfrom\n  file_visibility_change natural join\n  ctp_file natural join\n  file_series\nwhere \n  project_name = ? and site_name = ?\ngroup by \n  project_name, site_name, series_instance_uid, new_visibility, reason_for	{collection,site}	{project_name,site_name,series_instance_uid,new_visibility,reason_for,earliest,latest,num_files}	{Hierarchy,review_visibility_changes}	posda_files	Show all file visibility changes by series for collection, site
AllValuesByElementSigIdAndScanId	select\n  distinct value\nfrom\n  seen_value natural join scan_element\nwhere\n  element_signature_id = ? and series_scan_id in (\n  select\n    series_scan_id \n  from \n    series_scan\n  where \n    scan_event_id = ?\n  )\norder by value\n	{element_signature_id,scan_id}	{value}	{tag_usage}	posda_phi	List of values seen in scan with specified tag\n
ReviewEditsByTimeSpan	select\n  distinct project_name,\n  site_name,\n  series_instance_uid,\n  new_visibility,\n  reason_for,\n  min(time_of_change) as earliest,\n  max(time_of_change) as latest,\n  count(*) as num_files\nfrom\n  file_visibility_change natural join\n  ctp_file natural join\n  file_series\nwhere\n  time_of_change > ? and time_of_change < ?\ngroup by\n  project_name,\n  site_name,\n  series_instance_uid,\n  new_visibility,\n  reason_for	{from,to}	{project_name,site_name,series_instance_uid,new_visibility,reason_for,earliest,latest,num_files}	{Hierarchy,review_visibility_changes}	posda_files	Show all file visibility changes by series over a time range
GetSeriesWithImageByCollectionSite	select distinct\n  project_name as collection, site_name as site,\n  patient_id, modality, series_instance_uid, \n  count(distinct sop_instance_uid) as num_sops,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join file_sop_common\n  natural join file_patient\n  natural join file_image natural join ctp_file\n  natural join file_import natural join import_event\nwhere project_name = ? and site_name = ? and visibility is null\ngroup by\n  collection, site, patient_id, modality, series_instance_uid\n	{collection,site}	{collection,site,patient_id,modality,series_instance_uid,num_sops,num_files}	{signature,phi_review,visual_review}	posda_files	Get a list of Series with images by CollectionSite\n
DistinctSeriesByCollectionSiteIntake	select\n  distinct s.series_instance_uid, modality, count(*) as num_images\nfrom\n  general_image i, general_series s,\n  trial_data_provenance tdp\nwhere\n  s.general_series_pk_id = i.general_series_pk_id and\n  i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and tdp.dp_site_name = ?\ngroup by series_instance_uid, modality	{project_name,site_name}	{series_instance_uid,modality,num_images}	{by_collection,find_series,intake,compare_collection_site,simple_phi}	intake	Get Series in A Collection, Site\n
SeriesVisualReviewResultsByCollectionSite	select \n  distinct series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status,\n  processing_status,\n  count(distinct file_id) as num_files\nfrom \n  dicom_file natural join \n  file_series natural join \n  ctp_file join \n  image_equivalence_class using(series_instance_uid)\nwhere\n  project_name = ? and\n  site_name = ?\ngroup by\n  series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status,\n  processing_status\norder by\n  series_instance_uid	{project_name,site_name}	{series_instance_uid,dicom_file_type,modality,review_status,processing_status,num_files}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files}	posda_files	Get visual review status report by series for Collection, Site
AddPhiElement	insert into element_signature (\n  element_signature,\n  vr,\n  is_private,\n  private_disposition,\n  name_chain\n) values (\n  ?, ?, ?, ?, ?\n)\n	{element_signature,vr,is_private,private_disposition,name_chain}	{}	{NotInteractive,used_in_reconcile_tag_names}	posda_phi	Add an element_signature row to posda_phi
AddPhiSimpleElement	insert into element_seen (\n  element_sig_pattern,\n  vr,\n  is_private,\n  private_disposition,\n  tag_name\n) values (\n  ?, ?, ?, ?, ?\n)\n	{element_signature,vr,is_private,private_disposition,name_chain}	{}	{NotInteractive,used_in_reconcile_tag_names}	posda_phi_simple	Add an element_seen row to posda_phi_simple
PatientStudySeriesHierarchyByCollectionSiteExt	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid,\n  dicom_file_type,\n  modality,\n  count (distinct file_id) as num_files\nfrom\n  file_study natural join\n  ctp_file natural join\n  dicom_file natural join\n  file_series natural join\n  file_patient\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file\n    where project_name = ? and site_name = ? and\n    visibility is null\n  )\ngroup by patient_id, study_instance_uid, series_instance_uid,\n  dicom_file_type, modality\norder by patient_id, study_instance_uid, series_instance_uid	{collection,site}	{patient_id,study_instance_uid,series_instance_uid,dicom_file_type,modality,num_files}	{Hierarchy}	posda_files	Construct list of files in a collection, site in a Patient, Study, Series Hierarchy
ReviewEditsBySiteCollectionLike	select\n  distinct project_name,\n  site_name,\n  series_instance_uid, \n  new_visibility, \n  reason_for,\n  min(time_of_change) as earliest,\n  max(time_of_change) as latest,\n  count(*) as num_files\nfrom\n  file_visibility_change natural join\n  ctp_file natural join\n  file_series\nwhere \n  site_name = ? and project_name like ?\ngroup by \n  project_name, site_name, series_instance_uid, new_visibility, reason_for	{site,CollectionLike}	{project_name,site_name,series_instance_uid,new_visibility,reason_for,earliest,latest,num_files}	{Hierarchy,review_visibility_changes}	posda_files	Show all file visibility changes by series for site
DistinctSeriesByCollectionSitePublic	select\n  distinct s.series_instance_uid, modality, count(*) as num_images\nfrom\n  general_image i, general_series s,\n  trial_data_provenance tdp\nwhere\n  s.general_series_pk_id = i.general_series_pk_id and\n  i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and tdp.dp_site_name = ?\ngroup by series_instance_uid, modality	{project_name,site_name}	{series_instance_uid,modality,num_images}	{by_collection,find_series,intake,compare_collection_site,simple_phi}	public	Get Series in A Collection, Site\n
PatientStudySeriesHierarchyByCollectionSiteWithDateRange	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid\nfrom\n  file_study natural join \n  ctp_file natural join \n  file_series natural join \n  file_patient\nwhere \n  file_id in (\n    select distinct file_id\n    from \n      ctp_file  natural join\n      file_import natural join\n      import_event\n    where project_name = ? and site_name = ? and\n    visibility is null and\n    import_time > ? and import_time < ?\n  )\norder by patient_id, study_instance_uid, series_instance_uid	{collection,site,from,to}	{patient_id,study_instance_uid,series_instance_uid}	{Hierarchy,apply_disposition}	posda_files	Construct list of files in a collection, site in a Patient, Study, Series Hierarchy with upload times within a date range
PatientStudySeriesHierarchyByCollectionSite	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid\nfrom\n  file_study natural join ctp_file natural join file_series natural join file_patient\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file\n    where project_name = ? and site_name = ? and\n    visibility is null\n  )\norder by patient_id, study_instance_uid, series_instance_uid	{collection,site}	{patient_id,study_instance_uid,series_instance_uid}	{Hierarchy,apply_disposition}	posda_files	Construct list of files in a collection, site in a Patient, Study, Series Hierarchy
ListOfCollectionsAndSites	select \n    distinct project_name, site_name, count(*) \nfrom \n   ctp_file natural join file_study natural join\n   file_series\nwhere\n  visibility is null\ngroup by project_name, site_name\norder by project_name, site_name\n	{}	{project_name,site_name,count}	{AllCollections,universal}	posda_files	Get a list of collections and sites\n
DistinctSeriesByCollectionIntake	select\n  distinct s.series_instance_uid, modality, count(*) as num_images\nfrom\n  general_image i, general_series s,\n  trial_data_provenance tdp\nwhere\n  s.general_series_pk_id = i.general_series_pk_id and\n  i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ?\ngroup by series_instance_uid, modality	{project_name}	{series_instance_uid,modality,num_images}	{by_collection,find_series,intake}	intake	Get Series in A Collection\n
RoundSummary1DateRange	select\n  distinct round_id,\n  round_start, \n  round_end - round_start as duration, \n  round_end, \n  sum(num_entered + num_dups),\n  ((round_end - round_start) / sum(num_entered + num_dups)) as sec_per_file\nfrom\n  round natural join round_collection\nwhere\n  round_end is not null and round_start > ? and round_end < ?\ngroup by \n  round_id, round_start, duration, round_end \norder by round_id	{from,to}	{round_id,round_start,duration,round_end,sum,sec_per_file}	{NotInteractive,Backlog,"Backlog Monitor",backlog_analysis_reporting_tools}	posda_backlog	Summary of rounds
SeriesVisualReviewResultsByCollectionSiteStatusVisible	select \n  distinct series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status,\n  count(distinct file_id) as num_files\nfrom \n  dicom_file natural join \n  file_series natural join \n  ctp_file join \n  image_equivalence_class using(series_instance_uid)\nwhere\n  project_name = ? and\n  site_name = ? and review_status = ?\n  and visibility is null\ngroup by\n  series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status\norder by\n  series_instance_uid	{project_name,site_name,status}	{series_instance_uid,dicom_file_type,modality,review_status,num_files}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files}	posda_files	Get visual review status report by series for Collection, Site
TagsSeenPrivate	select\n  element_signature, vr, is_private, private_disposition, name_chain\nfrom\n  element_signature\nwhere is_private\norder by element_signature, vr	{}	{element_signature,vr,is_private,private_disposition,name_chain}	{by_collection,find_series,compare_collection_site,search_series,edit_files,phi_maint}	posda_phi	Get all the data from tags_seen in posda_phi database\n
DistinctSopsInCollectionSiteIntakeWithFile	select\n  distinct i.sop_instance_uid, i.dicom_file_uri\nfrom\n  general_image i,\n  trial_data_provenance tdp\nwhere\n  i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and tdp.dp_site_name = ?\norder by sop_instance_uid\n	{collection,site}	{sop_instance_uid,dicom_file_uri}	{by_collection,files,intake,sops,compare_collection_site}	intake	Get Distinct SOPs in Collection with number files\n
SeriesVisualReviewResultsByCollectionSiteStatus	select \n  distinct series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status,\n  count(distinct file_id) as num_files\nfrom \n  dicom_file natural join \n  file_series natural join \n  ctp_file join \n  image_equivalence_class using(series_instance_uid)\nwhere\n  project_name = ? and\n  site_name = ? and review_status = ?\ngroup by\n  series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status\norder by\n  series_instance_uid	{project_name,site_name,status}	{series_instance_uid,dicom_file_type,modality,review_status,num_files}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files}	posda_files	Get visual review status report by series for Collection, Site
CountsByCollectionSiteDateRange	select\n  distinct\n    patient_id, image_type, modality, study_date, study_description,\n    series_description, study_instance_uid, series_instance_uid,\n    manufacturer, manuf_model_name, software_versions,\n    count(distinct sop_instance_uid) as num_sops,\n    count(distinct file_id) as num_files,\n    min(import_time) as earliest,\n    max(import_time) as latest\nfrom\n  ctp_file join file_patient using(file_id)\n  join file_series using(file_id)\n  join file_sop_common using(file_id)\n  join file_study using(file_id)\n  join file_equipment using(file_id)\n  join file_import using(file_id)\n  join import_event using(import_event_id)\n  left join file_image using(file_id)\n  left join image using (image_id)\nwhere\n  project_name = ? and site_name = ? and visibility is null\n  and import_time > ? and import_time < ?\ngroup by\n  patient_id, image_type, modality, study_date, study_description,\n  series_description, study_instance_uid, series_instance_uid,\n  manufacturer, manuf_model_name, software_versions\norder by\n  patient_id, study_instance_uid, series_instance_uid, image_type,\n  modality, study_date, study_description,\n  series_description,\n  manufacturer, manuf_model_name, software_versions\n	{collection,site,from,to}	{patient_id,image_type,modality,study_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files,earliest,latest}	{counts,count_queries}	posda_files	Counts query by Collection, Site\n
DistinctSopsInCollectionSitePublicWithFile	select\n  distinct i.sop_instance_uid, i.dicom_file_uri\nfrom\n  general_image i,\n  trial_data_provenance tdp\nwhere\n  i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and tdp.dp_site_name = ?\norder by sop_instance_uid\n	{collection,site}	{sop_instance_uid,dicom_file_uri}	{by_collection,files,intake,sops,compare_collection_site}	public	Get Distinct SOPs in Collection with number files\n
SeriesVisualReviewResultsByCollectionSiteStatusNotGood	select \n  distinct series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status,\n  count(distinct file_id) as num_files\nfrom \n  dicom_file natural join \n  file_series natural join \n  ctp_file join \n  image_equivalence_class using(series_instance_uid)\nwhere\n  project_name = ? and\n  site_name = ? and review_status != 'Good'\ngroup by\n  series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status\norder by\n  series_instance_uid	{project_name,site_name}	{series_instance_uid,dicom_file_type,modality,review_status,num_files}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files}	posda_files	Get visual review status report by series for Collection, Site
DuplicateSopsInSeries	select\n  sop_instance_uid, import_time, file_id\nfrom \n  file_sop_common\n  natural join file_import natural join import_event\nwhere sop_instance_uid in (\nselect sop_instance_uid from (\nselect\n  distinct sop_instance_uid, count(distinct file_id) \nfrom\n  file_sop_common natural join file_series natural join ctp_file\nwhere\n  series_instance_uid = ? and visibility is null\ngroup by sop_instance_uid\n) as foo\nwhere count > 1\n)\norder by sop_instance_uid, import_time\n	{series_instance_uid}	{sop_instance_uid,import_time,file_id}	{by_series,dup_sops}	posda_files	List of Actual duplicate SOPs (i.e. different files, same SOP)\nin a series\n
SubjectCountsDateRangeSummaryByCollectionSite	select \n  distinct patient_id,\n  min(import_time) as from,\n  max(import_time) as to,\n  count(distinct file_id) as num_files,\n  count(distinct sop_instance_uid) as num_sops\nfrom \n  ctp_file natural join \n  file_sop_common natural join\n  file_patient natural join \n  file_import natural join \n  import_event\nwhere\n  project_name = ? and site_name = ? and visibility is null\ngroup by patient_id\norder by patient_id	{collection,site}	{patient_id,from,to,num_files,num_sops}	{counts,count_queries}	posda_files	Counts query by Collection, Site\n
DistinctSeriesByCollection	select distinct series_instance_uid, dicom_file_type, modality, count(*)\nfrom (\nselect distinct series_instance_uid, sop_instance_uid, dicom_file_type, modality from (\nselect\n   distinct series_instance_uid, modality, sop_instance_uid,\n   file_id, dicom_file_type\n from file_series natural join file_sop_common\n   natural join ctp_file natural join dicom_file\nwhere\n  project_name = ?\n  and visibility is null)\nas foo\ngroup by series_instance_uid, sop_instance_uid, dicom_file_type, modality)\nas foo\ngroup by series_instance_uid, dicom_file_type, modality\n	{collection}	{series_instance_uid,dicom_file_type,modality,count}	{by_collection,find_series,search_series,send_series,phi_simple,simple_phi}	posda_files	Get Series in A Collection\n
ListOfQueriesPerformed	select\n  query_invoked_by_dbif_id as id,\n  query_name,\n  query_end_time - query_start_time as duration,\n  invoking_user as invoked_by,\n  query_start_time as at, \n  number_of_rows\nfrom\n  query_invoked_by_dbif\n	{}	{id,query_name,duration,invoked_by,at,number_of_rows}	{AllCollections,q_stats}	posda_queries	Get a list of collections and sites\n
GetSeriesWithImageByCollectionSiteDateRange	select distinct\n  project_name as collection, site_name as site,\n  patient_id, modality, series_instance_uid, \n  count(distinct sop_instance_uid) as num_sops,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join file_sop_common\n  natural join file_patient\n  natural join file_image natural join ctp_file\n  natural join file_import natural join import_event\nwhere project_name = ? and site_name = ? and visibility is null\n  and import_time > ? and import_time < ?\ngroup by\n  collection, site, patient_id, modality, series_instance_uid\n	{collection,site,from,to}	{collection,site,patient_id,modality,series_instance_uid,num_sops,num_files}	{signature,phi_review,visual_review}	posda_files	Get a list of Series with images by CollectionSite\n
GetPopupDefinition	select\n  command_line, input_line_format\nfrom \n  spreadsheet_operation, popup_buttons\nwhere\n  operation_name = ?\n  and operation_name = btn_name\n  and object_class = 'Posda::ProcessPopup'	{operation_name}	{command_line,input_line_format}	{NotInteractive,used_in_process_popup}	posda_queries	Get description of popup operation from spreadsheet operation table
DuplicateSopsInSeriesDistinct	select\n  distinct sop_instance_uid,\n  count(distinct file_id) as num_files,\n  min(import_time) as earliest,\n  max(import_time) as latest\nfrom \n  file_sop_common\n  natural join file_import natural join import_event\nwhere sop_instance_uid in (\nselect sop_instance_uid from (\nselect\n  distinct sop_instance_uid, count(distinct file_id) \nfrom\n  file_sop_common natural join file_series natural join ctp_file\nwhere\n  series_instance_uid = ? and visibility is null\ngroup by sop_instance_uid\n) as foo\nwhere count > 1\n)\ngroup by sop_instance_uid\norder by sop_instance_uid	{series_instance_uid}	{sop_instance_uid,num_files,earliest,latest}	{by_series,dup_sops}	posda_files	List of Actual duplicate SOPs (i.e. different files, same SOP)\nin a series\n
DuplicateFilesBySop	select\n  distinct\n    project_name as collection, site_name as site,\n    patient_id, sop_instance_uid, modality, file_id,\n    root_path || '/' || file_location.rel_path as file_path,\n    count(*) as num_uploads,\n    min(import_time) as first_upload, \n    max(import_time) as last_upload\nfrom\n  ctp_file join file_patient using(file_id)\n  join file_sop_common using(file_id)\n  join file_series using(file_id)\n  join file_location using(file_id)\n  join file_storage_root using(file_storage_root_id)\n  join file_import using (file_id)\n  join import_event using (import_event_id)\nwhere\n  sop_instance_uid = ?\n  and visibility is null\ngroup by\n  project_name, site_name, patient_id, sop_instance_uid, modality, \n  file_id, file_path\norder by\n  collection, site, patient_id, sop_instance_uid, modality\n	{sop_instance_uid}	{collection,site,patient_id,sop_instance_uid,modality,file_id,file_path,num_uploads,first_upload,last_upload}	{duplicates}	posda_files	Counts query by Collection, Site\n
SubjectsWithDupSops	select\n  distinct collection, site, patient_id, count(*)\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id,\n    file_id\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid from (\n        select distinct sop_instance_uid, count(*) from (\n          select distinct file_id, sop_instance_uid \n          from\n            ctp_file natural join file_sop_common\n            natural join file_patient\n          where\n            visibility is null\n        ) as foo group by sop_instance_uid order by count desc\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\ngroup by collection, site, patient_id\n	{}	{collection,site,patient_id,count}	{duplicates,dup_sops}	posda_files	Return a count of duplicate SOP Instance UIDs\n
PatientStudySeriesHierarchyByCollectionMatchingSeriesDesc	select distinct\n  patient_id,\n  study_instance_uid,\n  series_instance_uid\nfrom\n  file_study natural join ctp_file natural join file_series natural join file_patient\nwhere \n  file_id in (\n    select distinct file_id\n    from ctp_file natural join file_series\n    where project_name = ? and visibility is null and series_description like ?\n  )\norder by patient_id, study_instance_uid, series_instance_uid	{collection,series_descriptions_matching}	{patient_id,study_instance_uid,series_instance_uid}	{Hierarchy}	posda_files	Construct list of series in a collection in a Patient, Study, Series Hierarchy excluding matching SeriesDescriptons
ListOfQueriesPerformedByQueryName	select\n  query_invoked_by_dbif_id as id,\n  query_name,\n  query_end_time - query_start_time as duration,\n  invoking_user as invoked_by,\n  query_start_time as at, \n  number_of_rows\nfrom\n  query_invoked_by_dbif\nwhere\n query_name = ?	{query_name}	{id,query_name,duration,invoked_by,at,number_of_rows}	{AllCollections,q_stats}	posda_queries	Get a list of collections and sites\n
FileIdByPixelType	select\n  distinct file_id\nfrom\n  image natural join file_image\nwhere\n  photometric_interpretation = ? and\n  samples_per_pixel = ? and\n  bits_allocated = ? and\n  bits_stored = ? and\n  high_bit = ? and\n  (pixel_representation = ?  or pixel_representation is null) and\n  (planar_configuration = ? or planar_configuration is null)\nlimit 100	{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,planar_configuration}	{file_id}	{all,find_pixel_types,posda_files}	posda_files	Get distinct pixel types\n
LongestRunningNQueriesByDate	select * from (\nselect query_invoked_by_dbif_id as id, query_name, query_end_time - query_start_time as duration,\ninvoking_user, query_start_time, number_of_rows\nfrom query_invoked_by_dbif\nwhere query_end_time is not null and\nquery_start_time > ? and query_end_time < ?\norder by duration desc) as foo\nlimit ?	{from,to,n}	{id,query_name,duration,invoking_user,query_start_time,number_of_rows}	{AllCollections,q_stats_by_date}	posda_queries	Get a list of collections and sites\n
SubjectsWithDupSopsByCollection	select\n  distinct collection, site, subj_id, \n  count(distinct file_id) as num_files,\n  count(distinct sop_instance_uid) as num_sops,\n  min(import_time) as earliest,\n  max(import_time) as latest\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    file_id, sop_instance_uid, import_time\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_import\n    natural join import_event\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid from (\n        select distinct sop_instance_uid, count(*) from (\n          select distinct file_id, sop_instance_uid \n          from\n            ctp_file natural join file_sop_common\n            natural join file_patient\n          where\n            project_name = ? and visibility is null\n        ) as foo group by sop_instance_uid order by count desc\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\ngroup by collection, site, subj_id\n	{collection}	{collection,site,subj_id,num_sops,num_files,earliest,latest}	{dup_sops}	posda_files	Return a count of duplicate SOP Instance UIDs\n
SubjectsWithDupSopsByCollectionSite	select\n  distinct collection, site, subj_id, \n  count(distinct file_id) as num_files,\n  count(distinct sop_instance_uid) as num_sops,\n  min(import_time) as earliest,\n  max(import_time) as latest\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    file_id, sop_instance_uid, import_time\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_import\n    natural join import_event\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid from (\n        select distinct sop_instance_uid, count(*) from (\n          select distinct file_id, sop_instance_uid \n          from\n            ctp_file natural join file_sop_common\n            natural join file_patient\n          where\n            project_name = ? and site_name = ?\n            and visibility is null\n        ) as foo group by sop_instance_uid order by count desc\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\ngroup by collection, site, subj_id\n	{collection,site}	{collection,site,subj_id,num_sops,num_files,earliest,latest}	{dup_sops}	posda_files	Return a count of duplicate SOP Instance UIDs\n
GetSsVolumeForStudySeriesCount	select \n  distinct for_uid, study_instance_uid, series_instance_uid,\n  sop_class as sop_class_uid, count(distinct sop_instance) as num_sops\n  from ss_for natural join ss_volume where structure_set_id in (\n    select \n      structure_set_id \n    from\n      file_structure_set fs, file_sop_common sc\n    where\n      sc.file_id = fs.file_id and sop_instance_uid = ?\n)\ngroup by for_uid, study_instance_uid, series_instance_uid, sop_class\n	{sop_instance_uid}	{for_uid,study_instance_uid,series_instance_uid,sop_class_uid,num_sops}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get Structure Set Volume\n\n
SopInstanceFilePathCountAndLoadTimesBySeries	select\n  distinct sop_instance_uid, file_id,\n  root_path || '/' || file_location.rel_path as path,\n  min(import_time) as first_loaded,\n  count(distinct import_time) as times_loaded,\n  max(import_time) as last_loaded\nfrom\n  file_location\n  natural join file_storage_root\n  join file_import using(file_id)\n  join import_event using (import_event_id)\n  natural join file_sop_common\n  natural join file_series\nwhere series_instance_uid = ?\ngroup by sop_instance_uid, file_id, path\norder by sop_instance_uid, first_loaded	{series_instance_uid}	{sop_instance_uid,file_id,path,first_loaded,times_loaded,last_loaded}	{SeriesSendEvent,by_series,find_files,for_send,for_comparing_dups,dup_sops}	posda_files	Get file path from id
FileIdPathTimesLoadedCountsBySopInstance	select\n  distinct file_id,\n  root_path || '/' || file_location.rel_path as path,\n  min(import_time) as first_loaded,\n  count(distinct import_time) as times_loaded,\n  max(import_time) as last_loaded\nfrom\n  file_location\n  natural join file_storage_root\n  join file_import using(file_id)\n  join import_event using (import_event_id)\n  natural join file_sop_common where sop_instance_uid = ?\ngroup by file_id, path\norder by first_loaded	{sop_instance_uid}	{file_id,path,first_loaded,times_loaded,last_loaded}	{SeriesSendEvent,by_series,find_files,for_send}	posda_files	Get file path from id
FilePathCountAndLoadTimesBySopInstance	select\n  distinct file_id,\n  root_path || '/' || file_location.rel_path as path,\n  min(import_time) as first_loaded,\n  count(distinct import_time) as times_loaded,\n  max(import_time) as last_loaded\nfrom\n  file_location\n  natural join file_storage_root\n  join file_import using(file_id)\n  join import_event using (import_event_id)\n  natural join file_sop_common\nwhere sop_instance_uid = ?\ngroup by file_id, path;	{sop_instance_uid}	{file_id,path,first_loaded,times_loaded,last_loaded}	{SeriesSendEvent,by_series,find_files,for_send,for_comparing_dups}	posda_files	Get file path from id
FirstFileForSopPosda	select\n  root_path || '/' || rel_path as path,\n  modality\nfrom \n  file_location natural join file_storage_root\n  natural join file_sop_common\n  natural join file_series\n  natural join ctp_file\nwhere\n  sop_instance_uid = ? and visibility is null\nlimit 1	{sop_instance_uid}	{path,modality}	{by_series,UsedInPhiSeriesScan}	posda_files	First files in series in Posda\n
FilePathByFileId	select\n  root_path || '/' || rel_path as path\nfrom\n  file_location natural join file_storage_root\nwhere\n  file_id = ?	{file_id}	{path}	{SeriesSendEvent,by_series,find_files,for_send,for_comparing_dups,used_in_file_import_into_posda}	posda_files	Get file path from id
GetPosdaFileCreationRoot	select file_storage_root_id, root_path from file_storage_root where current and storage_class = 'created'	{}	{file_storage_root_id,root_path}	{NotInteractive,Backlog,used_in_file_import_into_posda}	posda_files	Get the file_storage root for newly created files
GetSeriesWithSignatureByCollectionSite	select distinct\n  series_instance_uid, dicom_file_type, \n  modality|| ':' || coalesce(manufacturer, '<undef>') || ':' \n  || coalesce(manuf_model_name, '<undef>') ||\n  ':' || coalesce(software_versions, '<undef>') as signature,\n  count(distinct series_instance_uid) as num_series,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join file_equipment natural join ctp_file\n  natural join dicom_file\nwhere project_name = ? and site_name = ? and visibility is null\ngroup by series_instance_uid, dicom_file_type, signature\n	{collection,site}	{series_instance_uid,dicom_file_type,signature,num_series,num_files}	{signature,phi_review}	posda_files	Get a list of Series with Signatures by Collection\n
PhiScanStatus	select\n  scan_event_id as id,\n  scan_started as start_time,\n  scan_ended as end_time,\n  scan_ended - scan_started as duration,\n  scan_status as status,\n  scan_description as description,\n  num_series_to_scan as to_scan,\n  num_series_scanned as scanned\nfrom \n  scan_event\norder by id\n	{}	{id,description,start_time,end_time,duration,status,to_scan,scanned}	{tag_usage,phi_review}	posda_phi	Status of PHI scans\n
PhiScanStatusInProcess	select\n  scan_event_id as id,\n  scan_started as start_time,\n  scan_ended as end_time,\n  scan_ended - scan_started as duration,\n  scan_status as status,\n  scan_description as description,\n  num_series_to_scan as to_scan,\n  num_series_scanned as scanned,\n  (((now() - scan_started) / num_series_scanned) * (num_series_to_scan -\n  num_series_scanned)) + now() as projected_completion,\n  (cast(num_series_scanned as float) / \n    cast(num_series_to_scan as float)) * 100.0 as percentage\nfrom\n  scan_event\nwhere\n   num_series_to_scan > num_series_scanned\n   and num_series_scanned > 0\norder by id\n	{}	{id,description,start_time,end_time,duration,status,to_scan,scanned,percentage,projected_completion}	{tag_usage,phi_review}	posda_phi	Status of PHI scans\n
InsertEditImportEvent	insert into import_event(\n  import_type, import_comment, import_time\n) values (\n  ?, ?, now()\n)	{import_type,import_comment}	{}	{NotInteractive,Backlog,Transaction,used_in_file_import_into_posda}	posda_files	Insert an Import Event for an Edited File
FilePathComponentsByFileId	select\n  root_path, rel_path\nfrom\n  file_location natural join file_storage_root\nwhere\n  file_id = ?	{file_id}	{root_path,rel_path}	{SeriesSendEvent,by_series,find_files,for_send,for_comparing_dups,used_in_file_import_into_posda}	posda_files	Get file path from id
EquivalenceClassStatusSummary	select \n  distinct patient_id, study_instance_uid, series_instance_uid,\n  processing_status, count(*) \nfrom \n  image_equivalence_class natural join image_equivalence_class_input_image \n  natural join file_study natural join file_series natural join file_patient\ngroup by \n  patient_id, study_instance_uid, series_instance_uid, processing_status\norder by \n  patient_id, study_instance_uid, series_instance_uid, processing_status	{}	{patient_id,study_instance_uid,series_instance_uid,processing_status,count}	{find_series,equivalence_classes,consistency,visual_review}	posda_files	Find Series with more than n equivalence class
GetImportEventId	select  currval('import_event_import_event_id_seq') as id\n	{}	{id}	{NotInteractive,Backlog,used_in_file_import_into_posda}	posda_files	Get posda file id of created import_event row
InsertFileImportLong	insert into file_import(\n  import_event_id, file_id,  rel_path, rel_dir, file_name\n) values (\n  ?, ?, ?, ?, ?\n)\n	{import_event_id,file_id,rel_path,rel_dir,file_name}	{}	{NotInteractive,Backlog,used_in_file_import_into_posda}	posda_files	Create an import_event
RtstructSopsByCollectionSiteDateRange	select distinct\n  sop_instance_uid\nfrom\n  file_series natural join ctp_file natural join file_sop_common\n  natural join file_import natural join import_event\nwhere \n  project_name = ? and site_name = ?\n  and visibility is null and import_time > ? and \n  import_time < ?\n  and modality = 'RTSTRUCT'	{collection,site,from,to}	{sop_instance_uid}	{Hierarchy,apply_disposition,hash_unhashed}	posda_files	Construct list of files in a collection, site in a Patient, Study, Series Hierarchy
SeriesForPhi	select \n  series_instance_uid \nfrom \n  series_scan_instance\nwhere series_scan_instance_id in (\n  select series_scan_instance_id from (\n    select * from element_value_occurance \n    where\n      phi_scan_instance_id = ? and\n      element_seen_id in (\n        select element_seen_id from element_seen\n        where element_sig_pattern = ?\n      ) and \n      value_seen_id in (\n        select value_seen_id from value_seen\n        where value = ?\n      )\n  ) as foo\n)	{scan_id,element_sig_pattern,value}	{series_instance_uid}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
TagsSeenSimplePrivate	select\n  element_sig_pattern, vr, private_disposition, tag_name\nfrom\n  element_seen\nwhere\n  is_private\norder by element_sig_pattern	{}	{element_sig_pattern,vr,private_disposition,tag_name}	{by_collection,find_series,compare_collection_site,search_series,edit_files,phi_maint}	posda_phi_simple	Get all the data from tags_seen in posda_phi_simple database\n
TagsSeenSimplePrivateWithCount	select \n  distinct element_sig_pattern,\n  vr,\n  private_disposition, tag_name,\n  count(distinct value) as num_values\nfrom\n  element_seen natural left join\n  element_value_occurance\n  natural left join value_seen\nwhere\n  is_private \ngroup by element_sig_pattern, vr, private_disposition, tag_name\norder by element_sig_pattern;	{}	{element_sig_pattern,vr,private_disposition,tag_name,num_values}	{by_collection,find_series,compare_collection_site,search_series,edit_files,phi_maint}	posda_phi_simple	Get all the data from tags_seen in posda_phi_simple database\n
SeriesWithMultipleDupSopsByCollectionSite	select\n  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, \n  count(distinct sop_instance_uid) as num_sops,\n  count(distinct file_id) as num_files\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    study_instance_uid, series_instance_uid,\n    sop_instance_uid,\n    file_id\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_study natural join file_series\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid from (\n        select distinct sop_instance_uid, count(*) from (\n          select distinct file_id, sop_instance_uid \n          from\n            ctp_file natural join file_sop_common\n            natural join file_patient\n          where\n            visibility is null and project_name = ? and site_name = ?\n        ) as foo group by sop_instance_uid order by count desc\n      ) as foo \n      where count > 2\n    )\n    and visibility is null\n  ) as foo\ngroup by collection, site, subj_id, study_instance_uid, series_instance_uid\n\n	{collection,site}	{collection,site,subj_id,num_sops,num_files,study_instance_uid,series_instance_uid}	{duplicates}	posda_files	Return a count of duplicate SOP Instance UIDs\n
SeriesWithDupSopsByCollectionSite	select\n  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, \n  count(distinct sop_instance_uid) as num_sops,\n  count(distinct file_id) as num_files\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    study_instance_uid, series_instance_uid,\n    sop_instance_uid,\n    file_id\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_study natural join file_series\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid from (\n        select distinct sop_instance_uid, count(distinct file_id) from (\n          select distinct file_id, sop_instance_uid \n          from\n            ctp_file natural join file_sop_common\n            natural join file_patient\n          where\n            visibility is null and project_name = ? and site_name = ?\n        ) as foo group by sop_instance_uid order by count desc\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\ngroup by collection, site, subj_id, study_instance_uid, series_instance_uid\n\n	{collection,site}	{collection,site,subj_id,num_sops,num_files,study_instance_uid,series_instance_uid}	{duplicates,dup_sops,hide_dup_sops}	posda_files	Return a count of duplicate SOP Instance UIDs\n
GetSeriesWithSignatureByCollectionSiteDateRange	select distinct\n  series_instance_uid, dicom_file_type, \n  modality|| ':' || coalesce(manufacturer, '<undef>') || ':' \n  || coalesce(manuf_model_name, '<undef>') ||\n  ':' || coalesce(software_versions, '<undef>') as signature,\n  count(distinct series_instance_uid) as num_series,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join file_equipment natural join ctp_file\n  natural join dicom_file join file_import using(file_id)\n  join import_event using(import_event_id)\nwhere project_name = ? and site_name = ? and visibility is null\n  and import_time > ? and import_time < ?\ngroup by series_instance_uid, dicom_file_type, signature\n	{collection,site,from,to}	{series_instance_uid,dicom_file_type,signature,num_series,num_files}	{signature,phi_review}	posda_files	Get a list of Series with Signatures by Collection\n
GetNonSquareImageIds	select file_id from image natural join file_image  where pixel_rows != pixel_columns\noffset ? limit ?	{offset,limit}	{file_id}	{ImageEdit}	posda_files	Get list of dicom_edit_event
CurrentPatientStatiiByCollectionSite	select \n  distinct project_name as collection,\n  site_name as site,\n  patient_id,\n  patient_import_status\nfrom \n  ctp_file natural join file_patient natural left join patient_import_status\nwhere\n  visibility is null and project_name = ? and site_name = ?	{collection,site}	{collection,site,patient_id,patient_import_status}	{counts,count_queries,patient_status}	posda_files	Get the current status of all patients
ListOfQueriesPerformedByDate	select\n  query_invoked_by_dbif_id as id,\n  query_name,\n  query_end_time - query_start_time as duration,\n  invoking_user as invoked_by,\n  query_start_time as at, \n  number_of_rows\nfrom\n  query_invoked_by_dbif\nwhere query_start_time > ? and query_end_time < ?\n	{from,to}	{id,query_name,duration,invoked_by,at,number_of_rows}	{AllCollections,q_stats_by_date}	posda_queries	Get a list of collections and sites\n
ShowPopUps	select * from popup_buttons\n 	{}	{popup_button_id,name,object_class,btn_col,is_full_table,btn_name}	{AllCollections,universal}	posda_queries	Get a list of configured pop-up buttons
PublicFilesInSeries	select\n  dicom_file_uri as file_path\nfrom\n  general_image\nwhere\n  series_instance_uid = ?\n	{series_instance_uid}	{file_path}	{public,used_in_simple_phi}	public	List of all Series By Collection, Site on Intake\n
UnHideFile	update\n  ctp_file\nset\n  visibility = null\nwhere\n  file_id = ?\n	{file_id}	{}	{ImageEdit,NotInteractive}	posda_files	Hide a file\n
CurrentPatientStatii	select \n  distinct project_name as collection,\n  site_name as site,\n  patient_id,\n  patient_import_status\nfrom \n  ctp_file natural join file_patient natural left join patient_import_status\nwhere \n  visibility is null	{}	{collection,site,patient_id,patient_import_status}	{counts,count_queries,patient_status}	posda_files	Get the current status of all patients
SopsDupsInDifferentSeriesByCollectionSite	select\n  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, sop_instance_uid,\n  file_id, file_path\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    study_instance_uid, series_instance_uid,\n    sop_instance_uid,\n    file_id, root_path ||'/' || rel_path as file_path\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_study natural join file_series\n    join file_location using(file_id) join file_storage_root using(file_storage_root_id)\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid from (\n        select distinct sop_instance_uid, count(distinct file_id) from (\n          select distinct file_id, sop_instance_uid \n          from\n            ctp_file natural join file_sop_common\n            natural join file_patient\n          where\n            visibility is null and project_name = ? and site_name = ?\n        ) as foo group by sop_instance_uid order by count desc\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\norder by sop_instance_uid\n\n	{collection,site}	{collection,site,subj_id,study_instance_uid,series_instance_uid,sop_instance_uid,file_id,file_path}	{duplicates,dup_sops,hide_dup_sops,sops_different_series}	posda_files	Return a count of duplicate SOP Instance UIDs\n
DuplicatesInDifferentSeriesByCollectionSite	select\n  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, sop_instance_uid,\n  file_id, file_path\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    study_instance_uid, series_instance_uid,\n    sop_instance_uid,\n    file_id, root_path ||'/' || rel_path as file_path\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_study natural join file_series\n    join file_location using(file_id) join file_storage_root using(file_storage_root_id)\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid from (\n        select distinct sop_instance_uid, count(distinct file_id) from (\n          select distinct file_id, sop_instance_uid \n          from\n            ctp_file natural join file_sop_common\n            natural join file_patient\n          where\n            visibility is null and project_name = ? and site_name = ?\n        ) as foo group by sop_instance_uid order by count desc\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\norder by sop_instance_uid\n\n	{collection,site}	{collection,site,subj_id,study_instance_uid,series_instance_uid,sop_instance_uid,file_id,file_path}	{duplicates,dup_sops,hide_dup_sops,sops_different_series}	posda_files	Return a count of duplicate SOP Instance UIDs\n
DistinctSeriesByCollectionSiteSubject	select distinct patient_id, series_instance_uid, dicom_file_type, modality, count(*)\nfrom (\nselect distinct patient_id, series_instance_uid, sop_instance_uid, dicom_file_type, modality from (\nselect\n   distinct patient_id, series_instance_uid, modality, sop_instance_uid,\n   file_id, dicom_file_type\n from file_series natural join file_sop_common\n   natural join file_patient\n   natural join ctp_file natural join dicom_file\nwhere\n  project_name = ? and site_name = ? and patient_id = ?\n  and visibility is null)\nas foo\ngroup by patient_id, series_instance_uid, sop_instance_uid, dicom_file_type, modality)\nas foo\ngroup by patient_id, series_instance_uid, dicom_file_type, modality\n	{project_name,site_name,patient_id}	{patient_id,series_instance_uid,dicom_file_type,modality,count}	{by_collection,find_series,compare_collection_site,search_series,edit_files}	posda_files	Get Series in A Collection, site with dicom_file_type, modality, and sop_count\n
GetCurrentEditEventRowId	select currval('dicom_edit_event_dicom_edit_event_id_seq') as id	{}	{id}	{NotInteractive,used_in_import_edited_files}	posda_files	Get current dicom_edit_event_id\nFor use in scripts\nNot really intended for interactive use\n
GetFileIdAndVisibilityByDigest	select\n  f.file_id as id,\n  c.file_id as ctp_file_id,\n  c.visibility as visibility\nfrom\n  file f left join ctp_file c\n  using(file_id)\nwhere\n  f.file_id in (\n  select file_id\n  from\n     file\n  where\n     digest = ?\n)	{digest}	{id,ctp_file_id,visibility}	{NotInteractive,used_in_import_edited_files}	posda_files	Get file_id, and current visibility by digest\nFor use in scripts\nNot really intended for interactive use\n
IncrementEditsDone	update dicom_edit_event\n  set edits_done = edits_done + 1\nwhere\n  dicom_edit_event_id = ?	{dicom_edit_event_id}	{}	{Insert,NotInteractive,used_in_import_edited_files}	posda_files	Increment edits done in dicom_edit_event table\nFor use in scripts\nNot really intended for interactive use\n
GetAdverseFileEventsByEditEventId	select\n  adverse_file_event_id,\n  file_id,\n  event_description,\n  when_occured\nfrom\n  adverse_file_event natural join\n  dicom_edit_event_adverse_file_event\nwhere\n  dicom_edit_event_id = ?	{dicom_edit_event_id}	{adverse_file_event_id,file_id,event_description,when_occured}	{NotInteractive,used_in_import_edited_files}	posda_files	Get List of Adverse File Events for a given dicom_edit_event\nFor use in scripts\nNot really intended for interactive use\n
CloseDicomFileEditEvent	update dicom_edit_event\n  set time_completed = now(),\n  report_file = ?,\n  notification_sent = ?\nwhere\n  dicom_edit_event_id = ?	{report_file_id,notify,dicom_edit_event_id}	{}	{Insert,NotInteractive,used_in_import_edited_files}	posda_files	Increment edits done in dicom_edit_event table\nFor use in scripts\nNot really intended for interactive use\n
SeriesWithDupSopsByCollectionSiteDateRange	select\n  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, \n  count(distinct sop_instance_uid) as num_sops,\n  count(distinct file_id) as num_files\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    study_instance_uid, series_instance_uid,\n    sop_instance_uid,\n    file_id\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_study natural join file_series\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid \n      from (\n        select distinct sop_instance_uid, count(distinct file_id)\n        from file_sop_common natural join ctp_file\n        where visibility is null and sop_instance_uid in (\n          select distinct sop_instance_uid\n          from file_sop_common natural join ctp_file\n            join file_import using(file_id) \n            join import_event using(import_event_id)\n          where project_name = ? and site_name = ? and\n             visibility is null and import_time > ?\n              and import_time < ?\n        ) group by sop_instance_uid\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\ngroup by collection, site, subj_id, study_instance_uid, series_instance_uid\n\n	{collection,site,from,to}	{collection,site,subj_id,num_sops,num_files,study_instance_uid,series_instance_uid}	{duplicates,dup_sops,hide_dup_sops}	posda_files	Return a count of duplicate SOP Instance UIDs\n
PublicPatientsByCollectionSite	select\n  distinct p.patient_id as PID, count(distinct i.image_pk_id) as num_images\nfrom\n  general_image i,\n  general_series s,\n  study t,\n  patient p,\n  trial_data_provenance tdp,\n  general_equipment q\nwhere\n  i.general_series_pk_id = s.general_series_pk_id and\n  s.study_pk_id = t.study_pk_id and\n  s.general_equipment_pk_id = q.general_equipment_pk_id and\n  t.patient_pk_id = p.patient_pk_id and\n  p.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and\n  tdp.dp_site_name = ?\ngroup by PID\n	{collection,site}	{PID,num_images}	{public}	public	List of all Files Images By Collection, Site\n
IntakePatientsByCollectionSite	select\n  distinct p.patient_id as PID, count(distinct i.image_pk_id) as num_images\nfrom\n  general_image i,\n  general_series s,\n  study t,\n  patient p,\n  trial_data_provenance tdp,\n  general_equipment q\nwhere\n  i.general_series_pk_id = s.general_series_pk_id and\n  s.study_pk_id = t.study_pk_id and\n  s.general_equipment_pk_id = q.general_equipment_pk_id and\n  t.patient_pk_id = p.patient_pk_id and\n  p.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ? and\n  tdp.dp_site_name = ?\ngroup by PID\n	{collection,site}	{PID,num_images}	{intake}	intake	List of all Files Images By Collection, Site\n
RtdoseSopsByCollectionSiteDateRange	select distinct\n  sop_instance_uid\nfrom\n  file_series natural join ctp_file natural join file_sop_common\n  natural join file_import natural join import_event\nwhere \n  project_name = ? and site_name = ?\n  and visibility is null and import_time > ? and \n  import_time < ?\n  and modality = 'RTDOSE'	{collection,site,from,to}	{sop_instance_uid}	{Hierarchy,apply_disposition,hash_unhashed}	posda_files	Construct list of files in a collection, site in a Patient, Study, Series Hierarchy
InsertAdverseFileEvent	insert into adverse_file_event(\n  file_id, event_description, when_occured\n) values (?, ?, now())\n	{file_id,event_description}	{}	{Insert,NotInteractive,used_in_import_edited_files}	posda_files	Insert adverse_file_event row\nFor use in scripts\nNot really intended for interactive use\n
GetCurrentAdverseFileEvent	select currval('adverse_file_event_adverse_file_event_id_seq') as id	{}	{id}	{NotInteractive,used_in_import_edited_files}	posda_files	Get current dicom_edit_event_id\nFor use in scripts\nNot really intended for interactive use\n
LinkAFEtoEditEvent	insert into dicom_edit_event_adverse_file_event(\n  dicom_edit_event_id, adverse_file_event_id\n) values (?, ?)\n	{dicom_edit_event_id,adverse_file_event_id}	{}	{Insert,NotInteractive,used_in_import_edited_files}	posda_files	Insert row linking adverse_file_edit_event to dicom_edit_event\nFor use in scripts\nNot really intended for interactive use\n
SimplePhiReportAll	select \n  distinct element_sig_pattern as element, vr, value, tag_name as description, count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ?\ngroup by element_sig_pattern, vr, value, description\norder by vr, element	{scan_id}	{element,vr,value,description,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
SimplePhiReportSelectedVR	select \n  distinct element_sig_pattern as element, vr, value, count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ? and\n  vr in ('SH', 'OB', 'PN', 'DA', 'ST', 'AS', 'DT', 'LO', 'UI', 'CS', 'AE', 'LT', 'ST', 'UC', 'UN', 'UR', 'UT')\ngroup by element_sig_pattern, vr, value;	{scan_id}	{element,vr,value,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
GetFileIdVisibilityBySeriesInstanceUid	select distinct file_id, visibility\nfrom file_series natural left join ctp_file\nwhere series_instance_uid = ?	{series_instance_uid}	{file_id,visibility}	{ImageEdit,edit_files}	posda_files	Get File id and visibility for all files in a series
ShowAllHideEventsByCollectionSiteModality	select\n  file_id,\n  user_name,\n  time_of_change,\n  prior_visibility,\n  new_visibility,\n  reason_for\nfrom\n   file_visibility_change \nwhere file_id in (\n  select file_id \n  from ctp_file natural join file_series\n  where project_name = ? and site_name = ? and\n  modality = ?\n)	{collection,site,modality}	{file_id,user_name,time_of_change,prior_visibility,new_visibility,reason_for}	{show_hidden}	posda_files	Show All Hide Events by Collection, Site
PotentialDuplicateSopSeriesByCollectionSite	select distinct collection, site, subj_id, study_instance_uid, series_instance_uid, \ncount(distinct sop_instance_uid)\nfrom\n(select\n  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, sop_instance_uid,\n  file_id, file_path\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    study_instance_uid, series_instance_uid,\n    sop_instance_uid,\n    file_id, root_path ||'/' || rel_path as file_path\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_study natural join file_series\n    join file_location using(file_id) join file_storage_root using(file_storage_root_id)\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid from (\n        select distinct sop_instance_uid, count(distinct file_id) from (\n          select distinct file_id, sop_instance_uid \n          from\n            ctp_file natural join file_sop_common\n            natural join file_patient\n          where\n            visibility is null and project_name = ? and site_name = ?\n        ) as foo group by sop_instance_uid order by count desc\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\norder by sop_instance_uid\n) as foo\ngroup by collection, site, subj_id, study_instance_uid, series_instance_uid\n\n	{collection,site}	{collection,site,subj_id,study_instance_uid,series_instance_uid,count}	{duplicates,dup_sops,hide_dup_sops,sops_different_series}	posda_files	Return a count of duplicate SOP Instance UIDs\n
SubjectCountsDateRangeSummaryByCollectionSiteDateRange	select \n  distinct patient_id,\n  min(import_time) as from,\n  max(import_time) as to,\n  count(distinct file_id) as num_files,\n  count(distinct sop_instance_uid) as num_sops\nfrom \n  ctp_file natural join file_patient natural join file_import natural join import_event\n  natural join file_sop_common\nwhere\n  project_name = ? and site_name = ? and import_time > ? and\n  import_time < ?\ngroup by patient_id\norder by patient_id	{collection,site,from,to}	{patient_id,from,to,num_files,num_sops}	{counts,count_queries}	posda_files	Counts query by Collection, Site\n
RemoveTagFromQuery	update queries\nset tags = array_remove(tags, ?::text)\nwhere name = ?	{tag_name,query_name}	{}	{meta}	posda_queries	Remove a tag from a query
FilesInSeries	select\n  distinct root_path || '/' || rel_path as file\nfrom\n  file_location natural join file_storage_root\n  natural join ctp_file\n  natural join file_series\nwhere\n  series_instance_uid = ? and visibility is null\n	{series_instance_uid}	{file}	{by_series,find_files,used_in_simple_phi}	posda_files	Get files in a series from posda database\n
UpdateElementDispositionOnly	update element_signature set \n  private_disposition = ?\nwhere\n  element_signature = ? and\n  vr = ?\n	{private_disposition,element_signature,vr}	{}	{NotInteractive,Update,ElementDisposition}	posda_phi	Update Element Disposition\nFor use in scripts\nNot really intended for interactive use\n
TagsSeenPrivateWithCount	select\n  distinct element_signature, \n  vr, \n  private_disposition, \n  name_chain, \n  count(distinct value) as num_values\nfrom\n  element_signature natural left join\n  scan_element natural left join\n  seen_value\nwhere is_private\ngroup by element_signature, vr, private_disposition, name_chain\norder by element_signature, vr	{}	{element_signature,vr,private_disposition,name_chain,num_values}	{by_collection,find_series,compare_collection_site,search_series,edit_files,phi_maint}	posda_phi	Get all the data from tags_seen in posda_phi database\n
TagsSeenSimplePrivateWithCountAndNullDisp	select \n  distinct element_sig_pattern,\n  vr,\n  private_disposition, tag_name,\n  count(distinct value) as num_values\nfrom\n  element_seen natural left join\n  element_value_occurance\n  natural left join value_seen\nwhere\n  is_private and private_disposition is null\ngroup by element_sig_pattern, vr, private_disposition, tag_name\norder by element_sig_pattern;	{}	{element_sig_pattern,vr,private_disposition,tag_name,num_values}	{by_collection,find_series,compare_collection_site,search_series,edit_files,phi_maint}	posda_phi_simple	Get all the data from tags_seen in posda_phi_simple database\n
TagsSeenPrivateWithCountNullDisp	select\n  distinct element_signature, \n  vr, \n  private_disposition, \n  name_chain, \n  count(distinct value) as num_values\nfrom\n  element_signature natural left join\n  scan_element natural left join\n  seen_value\nwhere is_private and private_disposition is null\ngroup by element_signature, vr, private_disposition, name_chain\norder by element_signature, vr	{}	{element_signature,vr,private_disposition,name_chain,num_values}	{by_collection,find_series,compare_collection_site,search_series,edit_files,phi_maint}	posda_phi	Get all the data from tags_seen in posda_phi database\n
AddNewDataToRoiTable	update roi set\n  max_x = ?,\n  max_y = ?,\n  max_z = ?,\n  min_x = ?,\n  min_y = ?,\n  min_z = ?,\n  roi_interpreted_type = ?,\n  roi_obser_desc = ?,\n  roi_obser_label = ?\nwhere\n  roi_id = ?	{max_x,max_y,max_z,min_x,min_y,min_z,roi_interpreted_type,roi_obser_desc,roi_obser_label,roi_id}	{}	{NotInteractive,used_in_processing_structure_set_linkages}	posda_files	Get the file_storage root for newly created files
SimplePhiReportByScanVrScreenDeletedPT	select \n  distinct element_sig_pattern as element, vr, value, \n  tag_name as description, \n  private_disposition as disposition, count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ? and vr = ? and\n  private_disposition in ('k', 'oi', 'h', 'o', null)\ngroup by element_sig_pattern, vr, value, tag_name, private_disposition	{scan_id,vr}	{element,vr,value,description,disposition,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
AddTagToQuery	update queries\nset tags = array_append(tags, ?)\nwhere name = ?	{tag,name}	{}	{query_tags,meta,test,hello}	posda_queries	Add a tag to a query
CountsByCollectionSiteSubjectDateRange	select\n  distinct\n    patient_id, image_type, modality, study_date, study_description,\n    series_description, study_instance_uid, series_instance_uid,\n    manufacturer, manuf_model_name, software_versions,\n    count(distinct sop_instance_uid) as num_sops,\n    count(distinct file_id) as num_files,\n    min(import_time) as earliest,\n    max(import_time) as latest\nfrom\n  ctp_file join file_patient using(file_id)\n  join file_series using(file_id)\n  join file_sop_common using(file_id)\n  join file_study using(file_id)\n  join file_equipment using(file_id)\n  join file_import using(file_id)\n  join import_event using(import_event_id)\n  left join file_image using(file_id)\n  left join image using (image_id)\nwhere\n  project_name = ? and site_name = ? and patient_id = ? and visibility is null\n  and import_time > ? and import_time < ?\ngroup by\n  patient_id, image_type, modality, study_date, study_description,\n  series_description, study_instance_uid, series_instance_uid,\n  manufacturer, manuf_model_name, software_versions\norder by\n  patient_id, study_instance_uid, series_instance_uid, image_type,\n  modality, study_date, study_description,\n  series_description,\n  manufacturer, manuf_model_name, software_versions\n	{collection,site,subject,from,to}	{patient_id,image_type,modality,study_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files,earliest,latest}	{counts,count_queries}	posda_files	Counts query by Collection, Site\n
SeriesConsistency	select distinct\n  series_instance_uid, modality, series_number, laterality, series_date,\n  series_time, performing_phys, protocol_name, series_description,\n  operators_name, body_part_examined, patient_position,\n  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n  performed_procedure_step_start_date, performed_procedure_step_start_time,\n  performed_procedure_step_desc, performed_procedure_step_comments,\n  count(*)\nfrom\n  file_series natural join ctp_file\nwhere series_instance_uid = ? and visibility is null\ngroup by\n  series_instance_uid, modality, series_number, laterality, series_date,\n  series_time, performing_phys, protocol_name, series_description,\n  operators_name, body_part_examined, patient_position,\n  smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n  performed_procedure_step_start_date, performed_procedure_step_start_time,\n  performed_procedure_step_desc, performed_procedure_step_comments\n	{series_instance_uid}	{series_instance_uid,count,modality,series_number,laterality,series_date,series_time,performing_phys,protocol_name,series_description,operators_name,body_part_examined,patient_position,smallest_pixel_value,largest_pixel_value,performed_procedure_step_id,performed_procedure_step_start_date,performed_procedure_step_start_time,performed_procedure_step_desc,performed_procedure_step_comments}	{by_series,consistency,series_consistency}	posda_files	Check a Series for Consistency\n
FindInconsistentSeries	select series_instance_uid from (\nselect distinct series_instance_uid, count(*) from (\n  select distinct\n    series_instance_uid, modality, series_number, laterality, series_date,\n    series_time, performing_phys, protocol_name, series_description,\n    operators_name, body_part_examined, patient_position,\n    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n    performed_procedure_step_start_date, performed_procedure_step_start_time,\n    performed_procedure_step_desc, performed_procedure_step_comments,\n    count(*)\n  from\n    file_series natural join ctp_file\n  where\n    project_name = ? and visibility is null\n  group by\n    series_instance_uid, modality, series_number, laterality, series_date,\n    series_time, performing_phys, protocol_name, series_description,\n    operators_name, body_part_examined, patient_position,\n    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n    performed_procedure_step_start_date, performed_procedure_step_start_time,\n    performed_procedure_step_desc, performed_procedure_step_comments\n) as foo\ngroup by series_instance_uid\n) as foo\nwhere count > 1\n	{collection}	{series_instance_uid}	{consistency,find_series,series_consistency}	posda_files	Find Inconsistent Series\n
CreateSimplePhiScanRow	insert into phi_scan_instance(\ndescription, num_series, start_time, num_series_scanned,file_query\n)values(?, ?,now(), 0,?)	{description,num_series,file_query}	{}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Create a new Simple PHI scan
GetSimplePhiScanId	select currval('phi_scan_instance_phi_scan_instance_id_seq') as id	{}	{id}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Create a new Simple PHI scan
CreateSimpleSeriesScanInstance	insert into series_scan_instance(\nscan_instance_id, series_instance_uid, start_time\n)values(?, ?, now())	{scan_instance_id,series_instance_uid}	{}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Create a new Simple PHI scan
GetSimpleElementSeen	select\n  element_seen_id as id\nfrom \n  element_seen\nwhere\n  element_sig_pattern = ? and\n  vr = ?	{element_sig_pattern,vr}	{id}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Get an element_seen row by element, vr (if present)
CreateSimpleElementSeen	insert into \n   element_seen(element_sig_pattern, vr)\n   values(?, ?)\n	{element_sig_pattern,vr}	{}	{NotInteractive,used_in_simple_phi_maint,used_in_phi_maint}	posda_phi_simple	Create a new Simple PHI scan
GetSimpleElementSeenIndex	select currval('element_seen_element_seen_id_seq') as id	{}	{id}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Get index of newly created element_seen
FindInconsistentSeriesWithSubjectAndStudy	select distinct patient_id, study_instance_uid, series_instance_uid\nfrom file_patient natural join file_study natural join file_series\nwhere series_instance_uid in (\nselect series_instance_uid from (\nselect distinct series_instance_uid, count(*) from (\n  select distinct\n    series_instance_uid, modality, series_number, laterality, series_date,\n    series_time, performing_phys, protocol_name, series_description,\n    operators_name, body_part_examined, patient_position,\n    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n    performed_procedure_step_start_date, performed_procedure_step_start_time,\n    performed_procedure_step_desc, performed_procedure_step_comments,\n    count(*)\n  from\n    file_series natural join ctp_file\n  where\n    project_name = ? and visibility is null\n  group by\n    series_instance_uid, modality, series_number, laterality, series_date,\n    series_time, performing_phys, protocol_name, series_description,\n    operators_name, body_part_examined, patient_position,\n    smallest_pixel_value, largest_pixel_value, performed_procedure_step_id,\n    performed_procedure_step_start_date, performed_procedure_step_start_time,\n    performed_procedure_step_desc, performed_procedure_step_comments\n) as foo\ngroup by series_instance_uid\n) as foo\nwhere count > 1\n)	{collection}	{patient_id,study_instance_uid,series_instance_uid}	{consistency,find_series,series_consistency}	posda_files	Find Inconsistent Series\n
ShowFilesHiddenByCollectionSite	select \n  distinct project_name as collection,\n  site_name as site,\n  patient_id,\n  reason_for as reason,\n  prior_visibility as before,\n  new_visibility as after,\n  user_name as user,\n  count(distinct file_id) as num_files,\n  min(time_of_change) as earliest,\n  max(time_of_change) as latest\nfrom \n  file_visibility_change natural join\n  file_patient natural join\n  ctp_file\nwhere\n  project_name = ? and site_name = ?\ngroup by\n   collection, site, \n   patient_id,\n   reason, before, after, user_name\norder by\n  earliest, patient_id	{collection,site}	{collection,site,patient_id,reason,before,after,user,num_files,earliest,latest}	{show_hidden}	posda_files	Show Files Hidden By User Date Range
FilesEarlierThanDateByCollectionSite	select \n  distinct file_id, visibility as old_visibility\nfrom \n  ctp_file natural join file_import natural join import_event\nwhere\n  project_name = ? and site_name = ? and visibility is null\n  and import_time < ?\n 	{collection,site,before}	{file_id,old_visibility}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files,show_hidden}	posda_files	Show Received before date by collection, site
ShowAllHideEventsByCollectionSite	select\n  file_id,\n  user_name,\n  time_of_change,\n  prior_visibility,\n  new_visibility,\n  reason_for\nfrom\n   file_visibility_change \nwhere file_id in (\n  select file_id \n  from ctp_file \n  where project_name = ? and site_name = ? \n)	{collection,site}	{file_id,user_name,time_of_change,prior_visibility,new_visibility,reason_for}	{show_hidden}	posda_files	Show All Hide Events by Collection, Site
GetValuesForTag	select\n  distinct element_signature as tag, value\nfrom\n  scan_element natural join series_scan natural join\n  seen_value natural join element_signature\nwhere element_signature = ? and scan_event_id = ?\n	{tag,scan_id}	{tag,value}	{tag_values}	posda_phi	Find Values for a given tag for all scanned series in a phi scan instance\n
GetValuesByEleVr	select\n  distinct value\nfrom\n  element_signature\n  join scan_element using(element_signature_id)\n  join seen_value using (seen_value_id)\nwhere\n  element_signature = ? and vr = ?\n	{element_signature,vr}	{value}	{NotInteractive,Update,ElementDisposition}	posda_phi	Get All  values in posda_phi by element, vr
GetSimpleValuesForTag	select\n  distinct value\nfrom\n  element_seen natural join\n  element_value_occurance natural join\n  value_seen\nwhere element_sig_pattern = ? and vr = ?\n	{tag,vr}	{value}	{tag_values}	posda_phi_simple	Find Values for a given tag, vr in posda_phi_simple\n
GetSimpleValuesByEleVr	select\n  distinct value\nfrom\n  element_seen\n  join element_value_occurance using(element_seen_id)\n  join value_seen using(value_seen_id)\nwhere element_sig_pattern = ? and vr = ?\n	{tag,vr}	{value}	{tag_values}	posda_phi_simple	Find Values for a given tag, vr in posda_phi_simple\n
GetRoiContoursAndFiles	select distinct root_path || '/' || rel_path as file_path, roi_id, roi_contour_id, roi_num, contour_num, geometric_type, number_of_points \nfrom roi_contour natural join roi natural join structure_set natural join file_structure_set natural join file_storage_root natural join file_location\nwhere file_id = ?	{file_id}	{file_path,roi_id,roi_contour_id,roi_num,contour_num,geometric_type,number_of_points}	{"Structure Sets",sops,LinkageChecks}	posda_files	Get Structure Set Volume\n\n
SimplePhiReportByScanVr	select \n  distinct element_sig_pattern as element, vr, value, \n  tag_name as description, count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ? and vr = ?\ngroup by element_sig_pattern, vr, value, tag_name	{scan_id,vr}	{element,vr,value,description,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
GetRoiIdFromFileIdRoiNum	select\n  roi_id\nfrom\n  roi natural join structure_set natural join file_structure_set\nwhere \n  file_id =? and roi_num = ?	{file_id,roi_num}	{roi_id}	{NotInteractive,used_in_processing_structure_set_linkages}	posda_files	Get the file_storage root for newly created files
GetListOfUnprocessedStructureSets	select\n  file_id,\n  root_path || '/' || rel_path as path\nfrom\n  file_storage_root natural join file_location\nwhere file_id in (\n  select distinct file_id\n  from dicom_file df natural join ctp_file\n  where \n  dicom_file_type = 'RT Structure Set Storage'\n  and visibility is null\n  and not exists (\n    select file_id from file_roi_image_linkage r where r.file_id = df.file_id\n  )\n)	{}	{file_id,path}	{NotInteractive,used_in_processing_structure_set_linkages}	posda_files	Get the file_storage root for newly created files
FilesByModalityByCollectionSiteDateRange	select\n  distinct patient_id, modality, series_instance_uid, sop_instance_uid, \n  root_path || '/' || file_location.rel_path as path,\n  min(import_time) as earliest,\n  max(import_time) as latest\nfrom\n  file_patient natural join file_series natural join file_sop_common natural join ctp_file\n  natural join file_location natural join file_storage_root\n  join file_import using(file_id) join import_event using(import_event_id)\nwhere\n  modality = ? and\n  project_name = ? and \n  site_name = ? and\n  import_time > ? and import_time < ? and\n  visibility is null\ngroup by patient_id, modality, series_instance_uid, sop_instance_uid, path	{modality,collection,site,from,to}	{patient_id,modality,series_instance_uid,sop_instance_uid,path,earliest,latest}	{FindSubjects,intake,FindFiles}	posda_files	Find All Files with given modality in Collection, Site
DupSopsByCollectionSiteDateRange	select\n  distinct collection, site, subj_id, \n  sop_instance_uid,\n  count(distinct file_id) as num_files\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    study_instance_uid, series_instance_uid,\n    sop_instance_uid,\n    file_id\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_study natural join file_series\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid \n      from (\n        select distinct sop_instance_uid, count(distinct file_id)\n        from file_sop_common natural join ctp_file\n        where visibility is null and sop_instance_uid in (\n          select distinct sop_instance_uid\n          from file_sop_common natural join ctp_file\n            join file_import using(file_id) \n            join import_event using(import_event_id)\n          where project_name = ? and site_name = ? and\n             visibility is null and import_time > ?\n              and import_time < ?\n        ) group by sop_instance_uid\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\ngroup by collection, site, subj_id, sop_instance_uid\n\n	{collection,site,from,to}	{collection,site,subj_id,sop_instance_uid,num_files}	{duplicates,dup_sops,hide_dup_sops}	posda_files	Return a count of duplicate SOP Instance UIDs\n
DupSopsWithFileIdByCollectionSiteDateRange	select\n  distinct collection, site, subj_id, \n  sop_instance_uid,\n  file_id,\n  visibility\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    study_instance_uid, series_instance_uid,\n    sop_instance_uid,\n    file_id,\n    visibility\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_study natural join file_series\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid \n      from (\n        select distinct sop_instance_uid, count(distinct file_id)\n        from file_sop_common natural join ctp_file\n        where visibility is null and sop_instance_uid in (\n          select distinct sop_instance_uid\n          from file_sop_common natural join ctp_file\n            join file_import using(file_id) \n            join import_event using(import_event_id)\n          where project_name = ? and site_name = ? and\n             visibility is null and import_time > ?\n              and import_time < ?\n        ) group by sop_instance_uid\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\norder by sop_instance_uid\n\n\n	{collection,site,from,to}	{collection,site,subj_id,sop_instance_uid,file_id,visibility}	{duplicates,dup_sops,hide_dup_sops}	posda_files	Return a count of duplicate SOP Instance UIDs\n
ShowAllVisibilityChangesBySopInstance	select\n  file_id,\n  user_name,\n  time_of_change,\n  prior_visibility,\n  new_visibility,\n  reason_for\nfrom\n   file_visibility_change \nwhere file_id in (\n  select file_id \n  from file_sop_common\n  where sop_instance_uid = ?\n)\norder by time_of_change	{sop_instance_uid}	{file_id,user_name,time_of_change,prior_visibility,new_visibility,reason_for}	{show_hidden}	posda_files	Show All Hide Events by Collection, Site
DistinctVrByScan	select \n  distinct vr, count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ? \ngroup by vr	{scan_id}	{vr,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
ShowImportsBySopInstance	select \n  file_id, import_time, import_comment \nfrom \n  import_event natural join file_import \nwhere file_id in (\n  select file_id from file_sop_common where sop_instance_uid = ?\n)\norder by import_time	{sop_instance_uid}	{file_id,import_time,import_type,import_comment}	{show_hidden}	posda_files	Show All Hide Events by Collection, Site
TagsSeen	select\n  element_signature, vr, is_private, private_disposition, name_chain\nfrom\n  element_signature order by element_signature	{}	{element_signature,vr,is_private,private_disposition,name_chain}	{by_collection,find_series,compare_collection_site,search_series,edit_files,phi_maint}	posda_phi	Get all the data from tags_seen in posda_phi database\n
SeriesVisualReviewResultsByCollectionSiteSummary	select \n  distinct\n  dicom_file_type,\n  modality,\n  review_status,\n  count(distinct series_instance_uid) as num_series,\n  count(distinct file_id) as num_files\nfrom \n  dicom_file natural join \n  file_series natural join \n  ctp_file join \n  image_equivalence_class using(series_instance_uid)\nwhere\n  project_name = ? and\n  site_name = ?\ngroup by\n  dicom_file_type,\n  modality,\n  review_status\n	{project_name,site_name}	{dicom_file_type,modality,review_status,num_series,num_files}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files}	posda_files	Get visual review status report by series for Collection, Site
TotalsByDateRangeAndCollection	select \n    distinct project_name, site_name, count(*) as num_subjects,\n    sum(num_studies) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\nfrom (\n  select\n    distinct project_name, site_name, patient_id, count(*) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\n  from (\n    select\n       distinct project_name, site_name, patient_id, study_instance_uid, \n       count(*) as num_series, sum(num_files) as total_files\n    from (\n      select\n        distinct project_name, site_name, patient_id, study_instance_uid, \n        series_instance_uid, count(*) as num_files \n      from (\n        select\n          distinct project_name, site_name, patient_id, study_instance_uid,\n          series_instance_uid, sop_instance_uid \n        from\n           ctp_file natural join file_study natural join\n           file_series natural join file_sop_common natural join file_patient\n           natural join file_import natural join import_event\n        where\n          visibility is null and import_time >= ? and\n          import_time < ? and project_name = ?\n      ) as foo\n      group by\n        project_name, site_name, patient_id, \n        study_instance_uid, series_instance_uid\n    ) as foo\n    group by project_name, site_name, patient_id, study_instance_uid\n  ) as foo\n  group by project_name, site_name, patient_id\n) as foo\ngroup by project_name, site_name\norder by project_name, site_name\n	{start_time,end_time,project_name}	{project_name,site_name,num_subjects,num_studies,num_series,total_files}	{DateRange,Kirk,Totals,end_of_month}	posda_files	Get posda totals by date range\n
TagsSeenSimple	select\n  element_sig_pattern, vr, is_private, private_disposition, tag_name\nfrom\n  element_seen order by element_sig_pattern	{}	{element_sig_pattern,vr,is_private,private_disposition,tag_name}	{by_collection,find_series,compare_collection_site,search_series,edit_files,phi_maint}	posda_phi_simple	Get all the data from tags_seen in posda_phi_simple database\n
FastCurrentPatientStatii	select \n  patient_id,\n  patient_import_status\nfrom \n  patient_import_status\n	{}	{patient_id,patient_import_status}	{counts,count_queries,patient_status}	posda_files	Get the current status of all patients
CreateDicomFileEditRow	insert into dicom_file_edit(\n  dicom_edit_event_id, from_file_digest, to_file_digest\n) values (?, ?, ?)\n	{dicom_edit_event_id,from_file_digest,to_file_digest}	{}	{Insert,NotInteractive,used_in_import_edited_files}	posda_files	Insert dicom_edit_event row\nFor use in scripts\nNot really intended for interactive use\n
TotalsByDateRange	select \n    distinct project_name, site_name, count(*) as num_subjects,\n    sum(num_studies) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\nfrom (\n  select\n    distinct project_name, site_name, patient_id, count(*) as num_studies,\n    sum(num_series) as num_series, sum(total_files) as total_files\n  from (\n    select\n       distinct project_name, site_name, patient_id, study_instance_uid, \n       count(*) as num_series, sum(num_files) as total_files\n    from (\n      select\n        distinct project_name, site_name, patient_id, study_instance_uid, \n        series_instance_uid, count(*) as num_files \n      from (\n        select\n          distinct project_name, site_name, patient_id, study_instance_uid,\n          series_instance_uid, sop_instance_uid \n        from\n           ctp_file natural join file_study natural join\n           file_series natural join file_sop_common natural join file_patient\n           natural join file_import natural join import_event\n        where\n          visibility is null and import_time >= ? and\n          import_time < ? \n      ) as foo\n      group by\n        project_name, site_name, patient_id, \n        study_instance_uid, series_instance_uid\n    ) as foo\n    group by project_name, site_name, patient_id, study_instance_uid\n  ) as foo\n  group by project_name, site_name, patient_id\n) as foo\ngroup by project_name, site_name\norder by project_name, site_name\n	{from,to}	{project_name,site_name,num_subjects,num_studies,num_series,total_files}	{AllCollections,DateRange,Kirk,Totals,count_queries,end_of_month}	posda_files	Get posda totals by date range\n\n**WARNING:**  This query can run for a **LONG** time if you give it a large date range.\nIt is intended for short date ranges (i.e. "What came in last night?" or "What came in last month?")\n
InsertEditEventRow	insert into dicom_edit_event(\n  edit_desc_file, time_started, edit_comment, num_files, process_id, edits_done\n) values (?, now(), ?, ?, ?, 0)\n	{edit_desc_file,edit_comment,num_files,process_id}	{}	{Insert,NotInteractive,used_in_import_edited_files}	posda_files	Insert edit_event\nFor use in scripts\nNot really intended for interactive use\n
GetSsReferencingUnknownImages	select\n  project_name as collection,\n  site_name as site,\n  patient_id, file_id\nfrom\n  ctp_file natural join file_patient\nwhere file_id in (\nselect\n  distinct ss_file_id as file_id from \n(select\n  sop_instance_uid, ss_file_id \nfrom (\n  select \n    distinct linked_sop_instance_uid as sop_instance_uid, file_id as ss_file_id\n  from\n    file_roi_image_linkage\n  ) foo left join file_sop_common using(sop_instance_uid)\n  where\n  file_id is null\n) as foo\n)\norder by collection, site, patient_id, file_id\n	{}	{collection,site,patient_id,file_id}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
GetSsReferencingKnownImages	select\n  project_name as collection,\n  site_name as site,\n  patient_id, file_id\nfrom\n  ctp_file natural join file_patient\nwhere file_id in (\n  select\n    distinct ss_file_id as file_id \n  from (\n    select\n      sop_instance_uid, ss_file_id \n    from (\n      select \n        distinct\n           linked_sop_instance_uid as sop_instance_uid,\n           file_id as ss_file_id\n      from\n        file_roi_image_linkage\n    ) foo left join file_sop_common using(sop_instance_uid)\n    join ctp_file using(file_id)\n  where\n    visibility is null\n  ) as foo\n)\norder by collection, site, patient_id, file_id\n	{}	{collection,site,patient_id,file_id}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
GetSsVolumeReferencingUnknownImages	select \n  project_name as collection, \n  site_name as site, patient_id, \n  file_id \nfrom \n  ctp_file natural join file_patient \nwhere file_id in (\n   select\n    distinct file_id from ss_volume v \n    join ss_for using(ss_for_id) \n    join file_structure_set using (structure_set_id) \n  where \n     not exists (\n       select file_id \n       from file_sop_common s \n       where s.sop_instance_uid = v.sop_instance\n  )\n)\norder by collection, site, patient_id	{}	{collection,site,patient_id,file_id}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
GetSsVolumeReferencingKnownImages	select \n  project_name as collection, \n  site_name as site, patient_id, \n  file_id \nfrom \n  ctp_file natural join file_patient \nwhere file_id in (\n   select\n    distinct file_id from ss_volume v \n    join ss_for using(ss_for_id) \n    join file_structure_set using (structure_set_id) \n  where \n     exists (\n       select file_id \n       from file_sop_common s \n       where s.sop_instance_uid = v.sop_instance\n  )\n)\norder by collection, site, patient_id	{}	{collection,site,patient_id,file_id}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
GetDupContourCountsExtended	select\n  project_name as collection,\n  site_name as site,\n  patient_id,\n  file_id,\n  num_dup_contours\nfrom (\n  select \n    distinct file_id, count(*) as num_dup_contours\n  from\n    file_roi_image_linkage \n  where \n    contour_digest in (\n    select contour_digest\n    from (\n      select \n        distinct contour_digest, count(*)\n      from\n        file_roi_image_linkage group by contour_digest\n    ) as foo\n    where count > 1\n  ) group by file_id \n) foo join ctp_file using (file_id) join file_patient using(file_id)\norder by num_dup_contours desc	{}	{collection,site,patient_id,file_id,num_dup_contours}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
GetDupContourCounts	select \n  distinct file_id, count(*) as num_dup_contours\nfrom\n  file_roi_image_linkage \nwhere \n  contour_digest in (\n  select contour_digest\n  from (\n    select \n      distinct contour_digest, count(*)\n    from\n      file_roi_image_linkage group by contour_digest\n  ) as foo\n  where count > 1\n) group by file_id order by num_dup_contours desc	{}	{file_id,num_dup_contours}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
SimplePhiReportPrivateOnlyByScanVrScreenDeletedPT	select \n  distinct element_sig_pattern as element, vr, value, \n  tag_name as description, count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ? and vr = ? and\n  is_private and\n  private_disposition in ('k', 'oi', 'h', 'o')\ngroup by element_sig_pattern, vr, value, tag_name	{scan_id,vr}	{element,vr,value,description,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
GetSimilarDupContourCounts	select\n  distinct\n  project_name as collection,\n  site_name as site,\n  patient_id,\n  series_instance_uid,\n  sop_instance_uid,\n  file_id\nfrom\n   ctp_file\n   natural join file_patient\n   natural join file_series\n   natural join file_sop_common\nwhere file_id in (\n  select distinct file_id from (\n    select \n      distinct file_id, count(*) as num_dup_contours\n    from\n      file_roi_image_linkage \n    where \n      contour_digest in (\n      select contour_digest\n     from (\n        select \n          distinct contour_digest, count(*)\n        from\n          file_roi_image_linkage group by contour_digest\n     ) as foo\n      where count > 1\n    ) group by file_id order by num_dup_contours desc\n  ) as foo\n  where num_dup_contours = ?\n)\n	{num_dup_contours}	{collection,site,patient_id,series_instance_uid,sop_instance_uid,file_id}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
InsertDistinguishedValue	insert into distinguished_pixel_digest_pixel_value(\n  pixel_digest, pixel_value, num_occurances\n  ) values (\n  ?, ?, ?\n)	{pixel_digest,value,num_occurances}	{}	{duplicates,distinguished_digest}	posda_files	insert distinguished pixel digest
InsertDistinguishedDigest	insert into distinguished_pixel_digests(\n  pixel_digest,\n  type_of_pixel_data,\n  sample_per_pixel,\n  number_of_frames,\n  pixel_rows,\n  pixel_columns,\n  bits_stored,\n  bits_allocated,\n  high_bit,\n  pixel_mask,\n  num_distinct_pixel_values) values (\n  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n);	{pixel_digest,type_of_pixel_data,sample_per_pixel,number_of_frames,pixel_rows,pixel_columns,bits_stored,bits_allocated,high_bit,pixel_mask,num_distinct_pixel_values}	{}	{duplicates,distinguished_digest}	posda_files	insert distinguished pixel digest
SeriesWithDistinguishedDigests	select\n  distinct project_name as collection,\n  site_name as site,\n  patient_id,\n  series_instance_uid,\n  count(distinct sop_instance_uid) as num_sops\nfrom\n  ctp_file natural join\n  file_patient natural\n  join file_series natural\n  join file_sop_common\nwhere file_id in(\n  select file_id \n  from\n    file_image\n    join image using (image_id)\n    join unique_pixel_data using (unique_pixel_data_id)\n  where digest in (\n    select distinct pixel_digest as digest \n    from distinguished_pixel_digests\n  )\n) group by collection, site, patient_id, series_instance_uid	{}	{collection,site,patient_id,series_instance_uid,num_sops}	{duplicates,distinguished_digest}	posda_files	show series with distinguished digests and counts
PixelTypesWithGeoRGB	select\n  distinct photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  pixel_representation,\n  planar_configuration,\n  iop, count(distinct image_id) as num_images\nfrom\n  image natural left join image_geometry\nwhere\n  photometric_interpretation = 'RGB'\ngroup by photometric_interpretation,\n  samples_per_pixel, bits_allocated, bits_stored, high_bit, pixel_representation,\n  planar_configuration, iop\norder by photometric_interpretation\n	{}	{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,pixel_representation,planar_configuration,iop,num_images}	{find_pixel_types,image_geometry,posda_files,rgb}	posda_files	Get distinct pixel types with geometry and rgb\n
PixelTypes	select\n  distinct photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  coalesce(number_of_frames,1) > 1 as is_multi_frame,\n  pixel_representation,\n  planar_configuration,\n  modality,\n  dicom_file_type,\n  count(distinct file_id)\nfrom\n  image natural join file_image natural join file_series\n  natural join dicom_file\ngroup by\n  photometric_interpretation,\n  samples_per_pixel,\n  bits_allocated,\n  bits_stored,\n  high_bit,\n  is_multi_frame,\n  pixel_representation,\n  planar_configuration,\n  modality,\n  dicom_file_type\norder by\n  count desc	{}	{photometric_interpretation,samples_per_pixel,bits_allocated,bits_stored,high_bit,is_multi_frame,pixel_representation,planar_configuration,modality,dicom_file_type,count}	{all,find_pixel_types,posda_files}	posda_files	Get distinct pixel types\n
PatientStudySopCountByCollectionSite	select \n  distinct patient_id, study_instance_uid, \n  count(distinct sop_instance_uid) as num_sops\nfrom \n  ctp_file natural join \n  file_sop_common natural join\n  file_patient natural join \n  file_study\nwhere\n  project_name = ? and site_name = ? and visibility is null\ngroup by patient_id, study_instance_uid\norder by patient_id	{collection,site}	{patient_id,study_instance_uid,num_sops}	{counts,count_queries}	posda_files	For every patient in collection site, get a list of studies with a count of distinct SOPs in each study
SimplePhiReportByScanVrPublicOnly	select \n  distinct element_sig_pattern as element, vr, value, \n  tag_name as description, count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ? and vr = ?\n  and not is_private\ngroup by element_sig_pattern, vr, value, tag_name	{scan_id,vr}	{element,vr,value,description,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
FindQueryByTag	select\n  distinct name from (\n  select name, unnest(tags) as tag\n  from queries) as foo\nwhere\n  tag = ?	{tag_name}	{name}	{meta,test,hello}	posda_queries	Find all queries matching tag
SimplePhiReportByScanVrPrivateOnly	select \n  distinct element_sig_pattern as element, vr, value, \n  tag_name as description, private_disposition as disposition,\n  count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ? and vr = ?\n  and is_private\ngroup by element_sig_pattern, vr, value, tag_name, private_disposition	{scan_id,vr}	{element,vr,value,description,disposition,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
FindQueryNameMatching	select\n  distinct name\nfrom\n  queries\nwhere\n  name ~ ?\norder by name	{name_matching}	{name}	{meta,test,hello}	posda_queries	Find all queries with name matching arg
FindQueryMatching	select\n  distinct name\nfrom\n  queries\nwhere\n  query ~ ?\norder by name	{query_matching}	{name}	{meta,test,hello}	posda_queries	Find all queries with name matching arg
DeleteLastTagFromQuery	update queries \n  set tags = tags[1:(array_upper(tags,1) -1)]\nwhere name = ?	{name}	{}	{meta,test,hello,query_tags}	posda_queries	Add a tag to a query
ListOfAvailableQueriesByTag	select tag, name, description from (\n  select\n    unnest(tags) as tag,\n    name, description\n  from queries\n) as foo\nwhere tag = ?\norder by name	{tag}	{tag,name,description}	{AllCollections,q_list}	posda_queries	Get a list of available queries
FindTagsInQuery	select\n  tag from (\n  select name, unnest(tags) as tag\n  from queries) as foo\nwhere\n  name = ?	{name}	{tag}	{meta,test,hello,query_tags}	posda_queries	Find all queries matching tag
QueryByName	select\n  name, description, query,\n  array_to_string(tags, ',') as tags\nfrom queries\nwhere name = ?\n	{name}	{name,description,query,tags}	{AllCollections,queries}	posda_queries	Get a list of available queries
ListOfAvailableQueriesByTagLike	select distinct name, description, tags from (\n  select\n    unnest(tags) as tag,\n    name, description,\n    array_to_string(tags, ',') as tags\n  from queries\n) as foo\nwhere tag like ?\norder by name	{tag}	{name,description,tags}	{AllCollections,q_list}	posda_queries	Get a list of available queries
DeleteFirstTagFromQuery	update queries \n  set tags = tags[(array_lower(tags,1) + 1):(array_upper(tags,1))]\nwhere name = ?	{name}	{}	{meta,test,hello,query_tags}	posda_queries	Add a tag to a query
PrependTagToQuery	update queries\nset tags = array_prepend(?, tags)\nwhere name = ?	{tag,name}	{}	{meta,test,hello,query_tags}	posda_queries	Add a tag to a query
ListOfAvailableQueries	select\n  schema, name, description,\n  array_to_string(tags, ',') as tags\nfrom queries\norder by name	{}	{schema,name,description,tags}	{AllCollections,q_list}	posda_queries	Get a list of available queries
DuplicatePixelDataThatMatters	select image_id, count from (\n  select distinct image_id, count(*)\n  from (\n    select distinct image_id, file_id\n    from (\n      select\n        file_id, image_id, patient_id, study_instance_uid, \n        series_instance_uid, sop_instance_uid, modality\n      from\n        file_patient natural join file_series natural join \n        file_study natural join file_sop_common\n        natural join file_image\n      where file_id in (\n        select file_id\n        from (\n          select image_id, file_id \n          from file_image \n          where image_id in (\n            select image_id\n            from (\n              select distinct image_id, count(*)\n              from (\n                select distinct image_id, file_id\n                from file_image where file_id in (\n                  select distinct file_id\n                  from ctp_file\n                  where project_name = ? and visibility is null\n                )\n              ) as foo\n              group by image_id\n            ) as foo \n            where count > 1\n          )\n        ) as foo\n      )\n    ) as foo\n  ) as foo\n  group by image_id\n) as foo \nwhere count > 1;\n	{collection}	{image_id,count}	{pixel_duplicates}	posda_files	Return a list of files with duplicate pixel data,\nrestricted to those files which have parsed DICOM data\nrepresentations in Database.\n
SeriesWithDuplicatePixelDataThatMatters	select \n  distinct project_name as collection,\n  site_name as site,\n  patient_id,\n  series_instance_uid,\n  count(distinct file_id) as num_files\nfrom \n  file_series natural join file_image\n  natural join file_patient\n  natural join ctp_file\nwhere \n  visibility is null \n  and image_id in (\nselect image_id from (\n  select distinct image_id, count(*)\n  from (\n    select distinct image_id, file_id\n    from (\n      select\n        file_id, image_id, patient_id, study_instance_uid, \n        series_instance_uid, sop_instance_uid, modality\n      from\n        file_patient natural join file_series natural join \n        file_study natural join file_sop_common\n        natural join file_image\n      where file_id in (\n        select file_id\n        from (\n          select image_id, file_id \n          from file_image \n          where image_id in (\n            select image_id\n            from (\n              select distinct image_id, count(*)\n              from (\n                select distinct image_id, file_id\n                from file_image where file_id in (\n                  select distinct file_id\n                  from ctp_file\n                  where project_name = ? and visibility is null\n                )\n              ) as foo\n              group by image_id\n            ) as foo \n            where count > 1\n          )\n        ) as foo\n      )\n    ) as foo\n  ) as foo\n  group by image_id\n) as foo \nwhere count > 1\n) group by collection, site, patient_id, series_instance_uid\n	{collection}	{collection,site,series_instance_uid,patient_id,num_files}	{pixel_duplicates}	posda_files	Return a list of files with duplicate pixel data,\nrestricted to those files which have parsed DICOM data\nrepresentations in Database.\n
ComplexDuplicatePixelData	select \n  distinct project_name, site_name, patient_id, series_instance_uid, count(*)\nfrom \n  ctp_file natural join file_patient natural join file_series \nwhere \n  file_id in (\n    select \n      distinct file_id\n    from\n      file_image natural join image natural join unique_pixel_data\n      natural join ctp_file\n    where digest in (\n      select\n        distinct pixel_digest\n      from (\n        select\n          distinct pixel_digest, count(*)\n        from (\n          select \n            distinct unique_pixel_data_id, pixel_digest, project_name,\n            site_name, patient_id, count(*) \n          from (\n            select\n              distinct unique_pixel_data_id, file_id, project_name,\n              site_name, patient_id, \n              unique_pixel_data.digest as pixel_digest \n            from\n              image natural join file_image natural join \n              ctp_file natural join file_patient fq\n              join unique_pixel_data using(unique_pixel_data_id)\n            where visibility is null\n          ) as foo \n          group by \n            unique_pixel_data_id, project_name, pixel_digest,\n            site_name, patient_id\n        ) as foo \n        group by pixel_digest\n      ) as foo \n      where count = ?\n    )\n    and visibility is null\n  ) \ngroup by project_name, site_name, patient_id, series_instance_uid\norder by count desc;\n	{count}	{project_name,site_name,patient_id,series_instance_uid,count}	{pix_data_dups,pixel_duplicates}	posda_files	Find series with duplicate pixel count of <n>\n
DuplicatePixelDataByProject	select image_id, file_id\nfrom file_image where image_id in (\n  select image_id\n  from (\n    select distinct image_id, count(*)\n    from (\n      select distinct image_id, file_id \n      from file_image\n      where file_id in (\n        select\n          distinct file_id \n        from ctp_file\n        where project_name = ? and visibility is null\n      )\n    ) as foo\n    group by image_id\n  ) as foo\n  where count > 1\n)\norder by image_id;\n	{collection}	{image_id,file_id}	{pixel_duplicates}	posda_files	Return a list of files with duplicate pixel data\n
GetSeriesForPhiInfo	select \n  series_instance_uid\nfrom \n  series_scan_instance \nwhere series_scan_instance_id in (\n  select series_scan_instance_id \n  from element_value_occurance \n  where element_seen_id in (\n    select \n      element_seen_id \n    from element_seen \n    where element_sig_pattern = ? and vr = ?\n  )\n  and value_seen_id in (\n    select value_seen_id \n    from value_seen\n    where value = ?\n  )\n  and phi_scan_instance_id = ?\n)	{element,vr,value,scan_id}	{series_instance_uid}	{used_in_simple_phi,NotInteractive}	posda_phi_simple	Get an element_seen row by element, vr (if present)
ListOfAvailableQueriesBySchema	select\n  name, description,\n  array_to_string(tags, ',') as tags\nfrom queries\nwhere schema = ?\norder by name	{schema}	{name,description,tags}	{AllCollections,schema}	posda_queries	Get a list of available queries
SeriesWithDuplicatePixelDataTest	select \n  distinct project_name as collection,\n  site_name as site,\n  patient_id,\n  series_instance_uid,\n  count(distinct file_id) as num_files\nfrom \n  file_series natural join file_image\n  natural join file_patient\n  natural join ctp_file\nwhere \n  visibility is null \n  and image_id in (\nselect image_id from (\n  select distinct image_id, count(*)\n  from (\n    select distinct image_id, file_id\n    from (\n      select\n        file_id, image_id, patient_id, study_instance_uid, \n        series_instance_uid, sop_instance_uid, modality\n      from\n        file_patient natural join file_series natural join \n        file_study natural join file_sop_common\n        natural join file_image\n      where file_id in (\n        select file_id\n        from (\n          select image_id, file_id \n          from file_image \n          where image_id in (\n            select image_id\n            from (\n              select distinct image_id, count(distinct file_id)\n              from file_image natural join ctp_file\n              where project_name = ? and visibility is null\n              group by image_id\n            ) as foo \n            where count > 1\n          )\n        ) as foo\n      )\n    ) as foo\n  ) as foo\n  group by image_id\n) as foo \nwhere count > 1\n) group by collection, site, patient_id, series_instance_uid\n	{collection}	{collection,site,series_instance_uid,patient_id,num_files}	{pixel_duplicates}	posda_files	Return a list of files with duplicate pixel data,\nrestricted to those files which have parsed DICOM data\nrepresentations in Database.\n
PixelDataDuplicateCounts	select\n  distinct pixel_digest, count(*)\nfrom (\n   select \n       distinct unique_pixel_data_id, pixel_digest, project_name,\n       site_name, patient_id, count(*) \n  from (\n    select\n      distinct unique_pixel_data_id, file_id, project_name,\n      site_name, patient_id, \n      unique_pixel_data.digest as pixel_digest \n    from\n      image join file_image using(image_id)\n      join ctp_file using(file_id)\n      join file_patient fq using(file_id)\n      join unique_pixel_data using(unique_pixel_data_id)\n    where visibility is null\n  ) as foo \n  group by \n    unique_pixel_data_id, project_name, pixel_digest,\n    site_name, patient_id\n) as foo \ngroup by pixel_digest	{}	{pixel_digest,count}	{pix_data_dups,pixel_duplicates}	posda_files	Find digest with counts of files\n
SeriesByDistinguishedDigest	select\n  distinct project_name as collection,\n  site_name as site,\n  patient_id,\n  series_instance_uid,\n  count(distinct sop_instance_uid) as num_sops\nfrom\n  ctp_file natural join\n  file_patient natural\n  join file_series natural\n  join file_sop_common\nwhere file_id in(\n  select file_id \n  from\n    file_image\n    join image using (image_id)\n    join unique_pixel_data using (unique_pixel_data_id)\n  where digest = ?\n  ) and visibility is null\ngroup by collection, site, patient_id, series_instance_uid\norder by collection, site, patient_id	{distinguished_pixel_digest}	{collection,site,patient_id,series_instance_uid,num_sops}	{duplicates,distinguished_digest}	posda_files	show series with distinguished digests and counts
FilesByReviewStatusByCollectionSiteWithVisibility	select\n  distinct\n  file_id,\n  project_name as collection,\n  site_name as site,\n  patient_id,\n  series_instance_uid,\n  sop_instance_uid,\n  file_id,\n  visibility\nfrom\n  image_equivalence_class_input_image\n  join ctp_file using(file_id)\n  join file_patient using(file_id)\n  join file_series using(file_id)\n  join file_sop_common using(file_id)\nwhere \n  image_equivalence_class_id in (\n    select\n      image_equivalence_class_id \n    from\n      image_equivalence_class \n      join file_series using(series_instance_uid)\n      join ctp_file using(file_id)\n    where \n      project_name = ? and site_name = ?\n      and review_status = ?\n)	{collection,site,status}	{collection,site,patient_id,series_instance_uid,sop_instance_uid,file_id,visibility}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files}	posda_files	Get visual review status report by series for Collection, Site
DistinctPatientStudySeriesByCollection	select distinct\n  patient_id, \n  study_instance_uid,\n  series_instance_uid, \n  dicom_file_type,\n  modality, \n  count(distinct file_id) as num_files\nfrom\n  ctp_file\n  natural join dicom_file\n  natural join file_study\n  natural join file_series\n  natural join file_patient\nwhere\n  project_name = ? and\n  visibility is null\ngroup by\n  patient_id, \n  study_instance_uid,\n  series_instance_uid,\n  dicom_file_type,\n  modality\n  	{collection}	{patient_id,study_instance_uid,series_instance_uid,dicom_file_type,modality,num_files}	{by_collection,find_series,search_series,send_series}	posda_files	Get Series in A Collection\n
KnownBlankImagesInSeries	select distinct pixel_digest, count(*) as num_files from (\n  select file_id, digest as pixel_digest\n  from\n    file_image join image using (image_id) join unique_pixel_data using (unique_pixel_data_id)\n  where file_id in (select file_id from file_series natural join ctp_file where series_instance_uid = ?)\n)\nas foo group by pixel_digest	{series_instance_uid}	{pixel_digest,num_files}	{by_series}	posda_files	List of SOPs, files, and import times in a series\n
ListOfAvailableQueriesByNameLike	select schema, name, description, tags from (\n  select\n    schema, name, description,\n    array_to_string(tags, ',') as tags\n  from queries\n) as foo\nwhere name like ?\norder by name	{name_like}	{schema,name,description,tags}	{AllCollections,q_list}	posda_queries	Get a list of available queries
ListOfSchemas	select\n distinct schema\nfrom queries\norder by schema	{}	{schema}	{AllCollections,schema}	posda_queries	Get a list of available queries
RecentUploadsTest1	select\n        project_name,\n        site_name,\n        dicom_file_type,\n        count(*),\n        (extract(epoch from now() - max(import_time)) / 60)::int as minutes_ago,\n        to_char(max(import_time), 'HH24:MI') as time\n\n    from (\n        select \n          project_name,\n          site_name,\n          dicom_file_type,\n          sop_instance_uid,\n          import_time\n\n        from \n          file_import\n          natural join import_event\n          natural join ctp_file\n          natural join dicom_file\n          natural join file_sop_common\n          natural join file_patient\n\n        where import_time > now() - interval '1' day\n          and visibility is null\n    ) as foo\n    group by\n        project_name,\n        site_name,\n        dicom_file_type\n    order by minutes_ago asc;	{}	{project_name,site_name,dicom_file_type,count,minutes_ago,time}	{files}	posda_files	Show files received by Posda in the past day.
GetNumPixDups	select distinct num_pix_dups, count(*) as num_pix_digs\nfrom (\nselect\n  distinct pixel_digest, count(*) as num_pix_dups\nfrom (\n   select \n       distinct unique_pixel_data_id, pixel_digest, project_name,\n       site_name, patient_id, count(*) \n  from (\n    select\n      distinct unique_pixel_data_id, file_id, project_name,\n      site_name, patient_id, \n      unique_pixel_data.digest as pixel_digest \n    from\n      image join file_image using(image_id)\n      join ctp_file using(file_id)\n      join file_patient fq using(file_id)\n      join unique_pixel_data using(unique_pixel_data_id)\n    where visibility is null\n  ) as foo \n  group by \n    unique_pixel_data_id, project_name, pixel_digest,\n    site_name, patient_id\n) as foo \ngroup by pixel_digest) as foo\ngroup by num_pix_dups\norder by num_pix_digs desc	{}	{num_pix_dups,num_pix_digs}	{pix_data_dups,pixel_duplicates}	posda_files	Find series with duplicate pixel count of <n>\n
WhereSeriesSitsQuick	select distinct\n  project_name as collection,\n  site_name as site,\n  patient_id,\n  study_instance_uid,\n  series_instance_uid\nfrom\n  file_patient natural join\n  file_study natural join\n  file_series natural join\n  ctp_file\nwhere file_id in (\n  select\n    distinct file_id\n  from\n    file_series natural join ctp_file\n  where\n    series_instance_uid = ? and visibility is null\n  limit 1\n)	{series_instance_uid}	{collection,site,patient_id,study_instance_uid,series_instance_uid}	{by_series_instance_uid,posda_files,sops,used_in_simple_phi}	posda_files	Get Collection, Site, Patient, Study Hierarchy in which series resides\n
GetSsReferencingKnownImagesByCollection	select\n  project_name as collection,\n  site_name as site,\n  patient_id, file_id\nfrom\n  ctp_file natural join file_patient\nwhere file_id in (\n  select\n    distinct ss_file_id as file_id \n  from (\n    select\n      sop_instance_uid, ss_file_id \n    from (\n      select \n        distinct\n           linked_sop_instance_uid as sop_instance_uid,\n           file_id as ss_file_id\n      from\n        file_roi_image_linkage\n    ) foo left join file_sop_common using(sop_instance_uid)\n    join ctp_file using(file_id)\n  where\n    visibility is null\n  ) as foo\n)\nand project_name = ? and visibility is null\norder by collection, site, patient_id, file_id\n	{collection}	{collection,site,patient_id,file_id}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
DistinctDispositonsNeededSimple	select \n  distinct \n  element_seen_id as id, \n  element_sig_pattern,\n  vr,\n  tag_name\nfrom\n  element_seen\n  natural join element_value_occurance\n  natural join value_seen\nwhere\n  is_private and \n  private_disposition is null\n	{}	{id,element_sig_pattern,vr,tag_name}	{tag_usage,simple_phi_maint,phi_maint}	posda_phi_simple	Private tags with no disposition with values in phi_simple
GetBasicImageGeometry	select\n  iop, ipp\nfrom\n  file_series\n  join file_image using (file_id)\n  join image_geometry using (image_id)\nwhere \n  series_instance_uid = ?	{series_instance_uid}	{iop,ipp}	{NotInteractive,used_in_import_edited_files,used_in_check_circular_view}	posda_files	Get file_id, and current visibility by digest\nFor use in scripts\nNot really intended for interactive use\n
ListOfAvailableQueriesForDescEdit	select\n  name, description, query,\n  array_to_string(tags, ',') as tags\nfrom queries\norder by name	{}	{name,description,query,tags}	{AllCollections,q_list}	posda_queries	Get a list of available queries
ListOfAvailableQueriesForDescEditBySchema	select\n  name, description, query,\n  array_to_string(tags, ',') as tags\nfrom queries\nwhere schema = ?\norder by name	{schema}	{name,description,query,tags}	{AllCollections,schema}	posda_queries	Get a list of available queries
GetSsVolumeReferencingKnownImagesByCollection	select \n  project_name as collection, \n  site_name as site, patient_id, \n  file_id \nfrom \n  ctp_file natural join file_patient \nwhere file_id in (\n   select\n    distinct file_id from ss_volume v \n    join ss_for using(ss_for_id) \n    join file_structure_set using (structure_set_id) \n  where \n     exists (\n       select file_id \n       from file_sop_common s \n       where s.sop_instance_uid = v.sop_instance\n  )\n)\nand project_name = ?\nand visibility is null\norder by collection, site, patient_id	{collection}	{collection,site,patient_id,file_id}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
DispositonsNeededSimple	select \n  distinct \n  element_seen_id as id, \n  element_sig_pattern,\n  vr,\n  tag_name,\n  value\nfrom\n  element_seen\n  natural join element_value_occurance\n  natural join value_seen\nwhere\n  is_private and \n  private_disposition is null\n	{}	{id,element_sig_pattern,vr,tag_name,value}	{tag_usage,simple_phi_maint,phi_maint}	posda_phi_simple	Private tags with no disposition with values in phi_simple
SimplePublicPhiReportSelectedVR	select \n  distinct element_sig_pattern as element, vr, value, count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ? and\n  not is_private and\n  vr in ('SH', 'OB', 'PN', 'DA', 'ST', 'AS', 'DT', 'LO', 'UI', 'CS', 'AE', 'LT', 'ST', 'UC', 'UN', 'UR', 'UT')\ngroup by element_sig_pattern, vr, value\norder by vr, element_sig_pattern, value	{scan_id}	{element,vr,value,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
ComplexDuplicatePixelDataNew	select distinct project_name as collection,\nsite_name as site,\npatient_id as patient,\nseries_instance_uid, count(distinct file_id) as num_files\nfrom\nctp_file natural join file_patient\nnatural join file_series where file_id in (\nselect file_id from \nfile_image join image using(image_id) \njoin unique_pixel_data using (unique_pixel_data_id)\nwhere digest in (\nselect distinct pixel_digest as digest from (\nselect\n  distinct pixel_digest, count(*) as num_pix_dups\nfrom (\n   select \n       distinct unique_pixel_data_id, pixel_digest, project_name,\n       site_name, patient_id, count(*) \n  from (\n    select\n      distinct unique_pixel_data_id, file_id, project_name,\n      site_name, patient_id, \n      unique_pixel_data.digest as pixel_digest \n    from\n      image join file_image using(image_id)\n      join ctp_file using(file_id)\n      join file_patient fq using(file_id)\n      join unique_pixel_data using(unique_pixel_data_id)\n    where visibility is null\n  ) as foo \n  group by \n    unique_pixel_data_id, project_name, pixel_digest,\n    site_name, patient_id\n) as foo \ngroup by pixel_digest) as foo\nwhere num_pix_dups = ?))\ngroup by collection, site, patient, series_instance_uid\norder by num_files desc	{num_pix_dups}	{collection,site,patient,series_instance_uid,num_files}	{pix_data_dups,pixel_duplicates}	posda_files	Find series with duplicate pixel count of <n>\n
FindInconsistentStudyIgnoringStudyTime	select distinct study_instance_uid from (\n  select distinct study_instance_uid, count(*) from (\n    select distinct\n      study_instance_uid, study_date,\n      referring_phy_name, study_id, accession_number,\n      study_description, phys_of_record, phys_reading,\n      admitting_diag\n    from\n      file_study natural join ctp_file\n    where\n      project_name = ? and visibility is null\n    group by\n      study_instance_uid, study_date,\n      referring_phy_name, study_id, accession_number,\n      study_description, phys_of_record, phys_reading,\n      admitting_diag\n  ) as foo\n  group by study_instance_uid\n) as foo\nwhere count > 1\n	{collection}	{study_instance_uid}	{by_study,consistency,study_consistency}	posda_files	Find Inconsistent Studies\n
RoundSummaryWithCollectionDateRange	select\n  distinct round_id, collection,\n  round_start, \n  round_end - round_start as duration, \n  round_end\nfrom\n  round natural join round_collection\nwhere\n  round_end is not null and round_start > ? and round_end < ?\ngroup by \n  round_id, collection, round_start, duration, round_end \norder by round_id	{from,to}	{round_id,collection,round_start,duration,round_end}	{NotInteractive,Backlog,"Backlog Monitor",backlog_analysis_reporting_tools}	posda_backlog	Summary of rounds
GetSeriesWithImageByCollectionSitePatient	select distinct\n  project_name as collection, site_name as site,\n  patient_id, modality, series_instance_uid, \n  count(distinct sop_instance_uid) as num_sops,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join file_sop_common\n  natural join file_patient\n  natural join file_image natural join ctp_file\n  natural join file_import natural join import_event\nwhere \n  project_name = ? and \n  site_name = ? and \n  patient_id = ? and\n  visibility is null\ngroup by\n  collection, site, patient_id, modality, series_instance_uid\n	{collection,site,patient_id}	{collection,site,patient_id,modality,series_instance_uid,num_sops,num_files}	{signature,phi_review,visual_review}	posda_files	Get a list of Series with images by CollectionSite\n
RecordElementDispositionChangeSimple	insert into element_disposition_changed(\n  element_seen_id,\n  when_changed,\n  who_changed,\n  why_changed,\n  new_disposition\n) values (\n  ?, now(), ?, ?, ?)	{id,who,why,disp}	{}	{tag_usage,simple_phi,used_in_phi_maint}	posda_phi_simple	Private tags with no disposition with values in phi_simple
ListHiddenFilesByCollectionPatient	select\n  project_name as collection,\n  site_name as site,\n  patient_id,\n  series_instance_uid,\n  file_id,\n  visibility as old_visibility\nfrom\n  ctp_file natural join\n  file_patient natural join\n  file_series\nwhere\n  visibility is not null and\n  project_name = ? and\n  patient_id = ?	{collection,patient_id}	{collection,site,patient_id,series_instance_uid,file_id,old_visibility}	{find_series,equivalence_classes,consistency,visual_review_results,show_hidden}	posda_files	Show Received before date by collection, site
GetSsReferencingUnknownImagesByCollection	select\n  project_name as collection,\n  site_name as site,\n  patient_id, file_id\nfrom\n  ctp_file natural join file_patient\nwhere file_id in (\nselect\n  distinct ss_file_id as file_id from \n(select\n  sop_instance_uid, ss_file_id \nfrom (\n  select \n    distinct linked_sop_instance_uid as sop_instance_uid, file_id as ss_file_id\n  from\n    file_roi_image_linkage\n  ) foo left join file_sop_common using(sop_instance_uid)\n  where\n  file_id is null\n) as foo\n)\nand project_name = ? and visibility is null\norder by collection, site, patient_id, file_id\n	{collection}	{collection,site,patient_id,file_id}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
UpdateElementDispositionSimple	update\n  element_seen\nset\n  private_disposition = ?\nwhere\n  element_seen_id = ?	{disp,id}	{}	{tag_usage,used_in_phi_maint,phi_maint}	posda_phi_simple	Private tags with no disposition with values in phi_simple
GetSeriesWithImageAndNoEquivalenceClassByCollectionSiteDateRange	select distinct\n  project_name as collection, site_name as site,\n  patient_id, modality, series_instance_uid, \n  count(distinct sop_instance_uid) as num_sops,\n  count(distinct file_id) as num_files\nfrom\n  file_series fs natural join file_sop_common\n  natural join file_patient\n  natural join file_image natural join ctp_file\n  natural join file_import natural join import_event\nwhere project_name = ? and site_name = ? and visibility is null\n  and import_time > ? and import_time < ?\n  and (\n    select count(*) \n    from image_equivalence_class ie\n    where ie.series_instance_uid = fs.series_instance_uid\n  ) = 0\ngroup by\n  collection, site, patient_id, modality, series_instance_uid\n	{collection,site,from,to}	{collection,site,patient_id,modality,series_instance_uid,num_sops,num_files}	{signature,phi_review,visual_review}	posda_files	Get a list of Series with images by CollectionSite\n
DistinctSeriesByCollectionLikeSeriesDescription	select \n  distinct collection, \n  site, patient_id, series_instance_uid, \n  series_description,\n  dicom_file_type, modality, \n  count(distinct sop_instance_uid) as num_sops,\n  count(distinct file_id) as num_files\n  from (\n    select\n     distinct project_name as collection,\n     site_name as site,\n     patient_id, \n     series_instance_uid, \n     series_description,\n     dicom_file_type, \n     modality, sop_instance_uid,\n     file_id\n    from \n     file_series\n     natural join dicom_file\n     natural join file_sop_common \n     natural join file_patient\n     natural join ctp_file\n  where\n    project_name = ? \n    and site_name = ? \n    and series_description like ?\n    and visibility is null\n) as foo\ngroup by collection, site, patient_id, \n  series_instance_uid, series_description, dicom_file_type, modality\n	{collection,site,description}	{collection,site,patient_id,series_instance_uid,series_description,dicom_file_type,modality,num_sops,num_files}	{by_collection,find_series}	posda_files	Get Series in A Collection\n
SimplePhiReportAllPublicOnly	select \n  distinct '<' || element_sig_pattern || '>'  as element, length(value) as val_length,\n  vr, value, tag_name as description, count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ? and not is_private\ngroup by element_sig_pattern, vr, value, val_length, description\norder by vr, element, val_length	{scan_id}	{element,vr,value,description,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
GetSeriesWithOutImageByCollectionSite	select distinct\n  project_name as collection, site_name as site,\n  patient_id, modality, series_instance_uid, \n  count(distinct sop_instance_uid) as num_sops,\n  count(distinct file_id) as num_files\nfrom\n  file_series\n  natural join file_sop_common\n  natural join file_patient\n  natural join ctp_file ctp\n  natural join file_import natural join import_event\nwhere project_name = ? and site_name = ? and visibility is null\n  and not exists (select image_id from file_image fi where ctp.file_id = fi.file_id)\ngroup by\n  collection, site, patient_id, modality, series_instance_uid\n	{collection,site}	{collection,site,patient_id,modality,series_instance_uid,num_sops,num_files}	{signature,phi_review,visual_review}	posda_files	Get a list of Series with images by CollectionSite\n
SeriesVisualReviewResultsExtendedByCollectionSiteStatus	select \n  distinct \n  project_name as collection,\n  site_name as site,\n  patient_id,\n  series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status,\n  equivalence_class_number,\n  count(distinct file_id) as num_files\nfrom \n  dicom_file natural join \n  file_series natural join\n  file_patient natural join\n  ctp_file join \n  image_equivalence_class using(series_instance_uid)\nwhere\n  project_name = ? and\n  site_name = ? and review_status = ? and visibility is null\ngroup by\n  collection,\n  site,\n  patient_id,\n  series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status,\n  equivalence_class_number\norder by\n  series_instance_uid	{project_name,site_name,status}	{collection,site,series_instance_uid,patient_id,dicom_file_type,modality,review_status,num_files,equivalence_class_number}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files}	posda_files	Get visual review status report by series for Collection, Site
SimplePhiReportAllRelevantPrivateOnly	select \n  distinct '<' || element_sig_pattern || '>'  as element, length(value) as val_length,\n  vr, value, tag_name as description, private_disposition as disp, count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ? and is_private and private_disposition not in ('d', 'na')\ngroup by element_sig_pattern, vr, value, val_length, description, disp\norder by vr, element, val_length	{scan_id}	{element,vr,value,description,disp,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
SeriesEquivalenceClassResults	select\n  distinct series_instance_uid,\n  equivalence_class_number, \n  review_status,\n  count(distinct file_id) as files_in_class\nfrom\n  image_equivalence_class\n  natural join image_equivalence_class_input_image\nwhere series_instance_uid in (\n  select \n    distinct series_instance_uid\n  from\n    ctp_file\n    natural join file_series \n    join image_equivalence_class using(series_instance_uid) \n  where project_name = ? and visibility is null and review_status = ?\n) group by\n   series_instance_uid,\n   equivalence_class_number,\n   review_status\norder by series_instance_uid, equivalence_class_number	{project_name,status}	{series_instance_uid,equivalence_class_number,review_status,files_in_class}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files}	posda_files	Get visual review status report by series for Collection, Site
GetDupsFromSimilarDupContourCounts	select distinct roi_id, count(*) from file_roi_image_linkage where\ncontour_digest in (select contour_digest from (select\n  distinct contour_digest, count(*) from\n(select\n  distinct\n  project_name as collection,\n  site_name as site,\n  patient_id,\n  series_instance_uid,\n  sop_class_uid,\n  file_id,\n  contour_digest\nfrom\n   ctp_file\n   natural join file_patient\n   natural join file_series\n   natural join file_sop_common\n  natural join file_roi_image_linkage\nwhere file_id in (\n  select distinct file_id from (\n    select \n      distinct file_id, count(*) as num_dup_contours\n    from\n      file_roi_image_linkage \n    where \n      contour_digest in (\n      select contour_digest\n     from (\n        select \n          distinct contour_digest, count(*)\n        from\n          file_roi_image_linkage group by contour_digest\n     ) as foo\n      where count > 1\n    ) group by file_id order by num_dup_contours desc\n  ) as foo\n  where num_dup_contours = ?\n)\n) as foo\ngroup by contour_digest)\nas foo where count > 1)\ngroup by roi_id order by count desc\n	{num_dup_contours}	{roi_id,count}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
GetSeriesWithImageByCollection	select distinct\n  project_name as collection, site_name as site,\n  patient_id, modality, series_instance_uid, \n  count(distinct sop_instance_uid) as num_sops,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join file_sop_common\n  natural join file_patient\n  natural join file_image natural join ctp_file\n  natural join file_import natural join import_event\nwhere project_name = ? and visibility is null\ngroup by\n  collection, site, patient_id, modality, series_instance_uid\n	{collection}	{collection,site,patient_id,modality,series_instance_uid,num_sops,num_files}	{signature,phi_review,visual_review}	posda_files	Get a list of Series with images by CollectionSite\n
VisibleSeriesVisualReviewResultsByCollectionSiteStatus	select \n  distinct series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status,\n  count(distinct file_id) as num_files\nfrom \n  dicom_file natural join \n  file_series natural join \n  ctp_file join \n  image_equivalence_class using(series_instance_uid)\nwhere\n  project_name = ? and\n  site_name = ? and review_status = ?\n  and visibility is null\ngroup by\n  series_instance_uid,\n  dicom_file_type,\n  modality,\n  review_status\norder by\n  series_instance_uid	{project_name,site_name,status}	{series_instance_uid,dicom_file_type,modality,review_status,num_files}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files}	posda_files	Get visual review status report by series for Collection, Site
SeeIfDigestIsAlreadyKnownDistinguished	select count(*) from distinguished_pixel_digests where pixel_digest = ?	{pixel_digest}	{count}	{meta,test,hello}	posda_files	Find Duplicated Pixel Digest
GetPixelDescriptorByDigest	select\n  samples_per_pixel, \n  number_of_frames, \n  pixel_rows,\n  pixel_columns,\n  bits_stored,\n  bits_allocated,\n  high_bit, \n  file_offset,\n  root_path || '/' || rel_path as path\nfrom\n  image\n  natural join unique_pixel_data\n  natural join pixel_location\n  join file_location using (file_id)\n  join file_storage_root using (file_storage_root_id)\nwhere digest = ?\nlimit 1	{pixel_digest}	{samples_per_pixel,number_of_frames,pixel_rows,pixel_columns,bits_stored,bits_allocated,high_bit,file_offset,path}	{meta,test,hello}	posda_files	Find Duplicated Pixel Digest
FindDuplicatedPixelDigests	select\n  distinct pixel_digest, num_files\nfrom (\n  select\n    distinct digest as pixel_digest, count(distinct file_id) as num_files\n  from\n    file_image\n    join image using(image_id)\n    join unique_pixel_data using (unique_pixel_data_id)\n  group by digest\n) as foo\nwhere num_files > 3\norder by num_files desc\n\n	{}	{pixel_digest,num_files}	{meta,test,hello}	posda_files	Find Duplicated Pixel Digest
LongestRunningNQueries	select * from (\nselect query_invoked_by_dbif_id as id, query_name, query_end_time - query_start_time as duration,\ninvoking_user, query_start_time, number_of_rows\nfrom query_invoked_by_dbif\nwhere query_end_time is not null\norder by duration desc) as foo\nlimit ?	{n}	{id,query_name,duration,invoking_user,query_start_time,number_of_rows}	{AllCollections,q_stats}	posda_queries	Get a list of collections and sites\n
ListOfQueriesPerformedByUserByDate	select\n  query_invoked_by_dbif_id as id,\n  query_name,\n  query_end_time - query_start_time as duration,\n  invoking_user as invoked_by,\n  query_start_time as at, \n  number_of_rows\nfrom\n  query_invoked_by_dbif\nwhere\n  invoking_user = ? and\n  query_start_time > ? and query_end_time < ?\norder by query_start_time	{user,from,to}	{id,query_name,duration,invoked_by,at,number_of_rows}	{AllCollections,q_stats_by_date}	posda_queries	Get a list of collections and sites\n
CurrentPatientWithoutStatii	select \n  distinct project_name as collection,\n  site_name as site,\n  patient_id,\n  '<undef>' as patient_import_status\nfrom \n  ctp_file natural join file_patient p\nwhere \n  visibility is null and\n  not exists (select * from patient_import_status s where p.patient_id = s.patient_id)	{}	{collection,site,patient_id,patient_import_status}	{counts,count_queries,patient_status}	posda_files	Get the current status of all patients
DistinctPatientStudySeriesByCollectionSite	select distinct\n  patient_id, \n  study_instance_uid,\n  series_instance_uid, \n  dicom_file_type,\n  modality, \n  count(distinct file_id) as num_files\nfrom\n  ctp_file\n  natural join dicom_file\n  natural join file_study\n  natural join file_series\n  natural join file_patient\nwhere\n  project_name = ? and\n  site_name = ? and\n  visibility is null\ngroup by\n  patient_id, \n  study_instance_uid,\n  series_instance_uid,\n  dicom_file_type,\n  modality\n  	{collection,site}	{patient_id,study_instance_uid,series_instance_uid,dicom_file_type,modality,num_files}	{by_collection,find_series,search_series,send_series}	posda_files	Get Series in A Collection\n
CountsByCollectionDateRangePlus	select\n  distinct\n    patient_id, image_type, dicom_file_type, modality,\n    study_date, series_date,\n    study_description,\n    series_description, study_instance_uid, series_instance_uid,\n    manufacturer, manuf_model_name, software_versions,\n    count(distinct sop_instance_uid) as num_sops,\n    count(distinct file_id) as num_files,\n    min(import_time) as earliest,\n    max(import_time) as latest\nfrom\n  ctp_file join file_patient using(file_id)\n  join dicom_file using(file_id)\n  join file_series using(file_id)\n  join file_sop_common using(file_id)\n  join file_study using(file_id)\n  join file_equipment using(file_id)\n  join file_import using(file_id)\n  join import_event using(import_event_id)\n  left join file_image using(file_id)\n  left join image using (image_id)\nwhere\n  file_id in (\n    select file_id \n    from file_import natural join import_event\n    where import_time > ? and import_time < ?\n  ) and project_name = ? and visibility is null\ngroup by\n  patient_id, image_type, dicom_file_type, modality, study_date, \n  series_date, study_description,\n  series_description, study_instance_uid, series_instance_uid,\n  manufacturer, manuf_model_name, software_versions\norder by\n  patient_id, study_instance_uid, series_instance_uid, image_type,\n  modality, study_date, series_date, study_description,\n  series_description,\n  manufacturer, manuf_model_name, software_versions\n	{from,to,collection}	{patient_id,image_type,dicom_file_type,modality,study_date,series_date,study_description,series_description,study_instance_uid,series_instance_uid,manufacturer,manuf_model_name,software_versions,num_sops,num_files,earliest,latest}	{counts,count_queries}	posda_files	Counts query by Collection, Site\n
FindPotentialDistinguishedPixelDigests	select \n  distinct project_name as collection,\n  site_name as site,\n  patient_id,\n  series_instance_uid,\n  modality,\n  dicom_file_type,\n  digest as pixel_digest,\n  pixel_rows,\n  pixel_columns,\n  bits_allocated,\n  count(*)\nfrom\n  ctp_file\n  natural join file_patient\n  natural join file_series\n  natural join file_image\n  natural join dicom_file\n  join image using (image_id)\n  join unique_pixel_data using(unique_pixel_data_id)\nwhere\n  file_id in \n  (select \n    distinct file_id \n  from\n    file_image \n  where\n    image_id in\n    (select\n       image_id from \n       (select\n         distinct image_id, count(distinct file_id) \n       from\n         file_image \n       group by image_id\n       ) as foo\n     where count > 10\n  )\n) and visibility is null \ngroup by collection, site, patient_id, series_instance_uid,\nmodality, dicom_file_type,\ndigest, pixel_rows, pixel_columns, bits_allocated\norder by digest, collection, site, patient_id\n\n	{}	{collection,site,patient_id,series_instance_uid,modality,dicom_file_type,pixel_digest,pixel_rows,pixel_columns,bits_allocated,count}	{duplicates,distinguished_digest}	posda_files	Return a count of duplicate SOP Instance UIDs\n
DistinctSeriesByCollectionPublicTest	select\n  distinct s.series_instance_uid, modality, count(*) as num_images\nfrom\n  general_image i, general_series s,\n  trial_data_provenance tdp\nwhere\n  s.general_series_pk_id = i.general_series_pk_id and\n  i.trial_dp_pk_id = tdp.trial_dp_pk_id and\n  tdp.project = ?\ngroup by series_instance_uid, modality	{project_name}	{series_instance_uid,modality,num_images}	{by_collection,find_series,intake,compare_collection_site,simple_phi}	public	Get Series in A Collection, Site\n
PrivateTagsWhichArentMarked	select \n  distinct \n  element_seen_id as id, \n  element_sig_pattern,\n  vr,\n  tag_name,\n  private_disposition as disp\nfrom\n  element_seen\nwhere\n  is_private is null and \n  element_sig_pattern like '%"%'\n	{}	{id,element_sig_pattern,vr,tag_name,disp}	{tag_usage,simple_phi,simple_phi_maint,phi_maint}	posda_phi_simple	Private tags with no disposition with values in phi_simple
MarkPrivateTags	update element_seen set\n  is_private = true\nwhere\n  is_private is null and \n  element_sig_pattern like '%"%'\n	{}	{id,element_sig_pattern,vr,tag_name,disp}	{tag_usage,simple_phi,simple_phi_maint,phi_maint}	posda_phi_simple	Private tags with no disposition with values in phi_simple
QueryArgsByQueryId	select\n  arg_index as num, arg_name as name, arg_value as value\nfrom\n  dbif_query_args\nwhere\n  query_invoked_by_dbif_id = ?\norder by arg_index	{id}	{num,name,value}	{AllCollections,q_stats}	posda_queries	Get a list of collections and sites\n
ListOfQueriesPerformedByUser	select\n  query_invoked_by_dbif_id as id,\n  query_name,\n  query_end_time - query_start_time as duration,\n  invoking_user as invoked_by,\n  query_start_time as at, \n  number_of_rows\nfrom\n  query_invoked_by_dbif\nwhere\n  invoking_user = ?	{user}	{id,query_name,duration,invoked_by,at,number_of_rows}	{AllCollections,q_stats}	posda_queries	Get a list of collections and sites\n
PublicSeriesByCollectionMetadata	select\n  p.patient_id as PID,\n  s.modality as Modality,\n  t.study_date as StudyDate,\n  t.study_desc as StudyDescription,\n  s.series_desc as SeriesDescription,\n  s.series_number as SeriesNumber,\n  t.study_instance_uid as StudyInstanceUID,\n  s.series_instance_uid as SeriesInstanceUID,\n  q.manufacturer as Mfr,\n  q.manufacturer_model_name as Model,\n  q.software_versions,\n   count( i.sop_instance_uid) as Images\nfrom\n  general_image i,\n  general_series s,\n  study t,\n  patient p,\n  trial_data_provenance tdp,\n  general_equipment q\nwhere\n  i.general_series_pk_id = s.general_series_pk_id and\n  s.study_pk_id = t.study_pk_id and\n  s.general_equipment_pk_id = q.general_equipment_pk_id and\n  t.patient_pk_id = p.patient_pk_id and\n  p.trial_dp_pk_id = tdp.trial_dp_pk_id and \n  tdp.project = ? \ngroup by PID, StudyDate, Modality\n	{collection}	{PID,Modality,StudyDate,StudyDescription,SeriesDescription,SeriesNumber,StudyInstanceUID,SeriesInstanceUID,Mfr,Model,software_versions,Images}	{public}	public	List of all Series By Collection, Site on Public with metadata\n
PublicSeriesByCollectionVisibilityMetadata	select\n  p.patient_id as PID,\n  s.modality as Modality,\n  t.study_date as StudyDate,\n  t.study_desc as StudyDescription,\n  s.series_desc as SeriesDescription,\n  s.series_number as SeriesNumber,\n  t.study_instance_uid as StudyInstanceUID,\n  s.series_instance_uid as SeriesInstanceUID,\n  q.manufacturer as Mfr,\n  q.manufacturer_model_name as Model,\n  q.software_versions,\n   count(distinct  i.sop_instance_uid) as Images\nfrom\n  general_image i,\n  general_series s,\n  study t,\n  patient p,\n  trial_data_provenance tdp,\n  general_equipment q\nwhere\n  i.general_series_pk_id = s.general_series_pk_id and\n  s.study_pk_id = t.study_pk_id and\n  s.general_equipment_pk_id = q.general_equipment_pk_id and\n  t.patient_pk_id = p.patient_pk_id and\n  p.trial_dp_pk_id = tdp.trial_dp_pk_id and \n  tdp.project = ? and\n  s.visibility = ?\ngroup by PID, StudyDate, Modality\n	{collection,visibility}	{PID,Modality,StudyDate,StudyDescription,SeriesDescription,SeriesNumber,StudyInstanceUID,SeriesInstanceUID,Mfr,Model,software_versions,Images}	{public}	public	List of all Series By Collection, Site on Public with metadata\n
VisibilityChangeEventsByCollectionForHiddenFiles	select\n  distinct project_name as collection, \n  site_name as site, patient_id,\n  user_name, \n  date_trunc('hour',time_of_change) as time, \n  reason_for, count(*)\nfrom\n  file_visibility_change natural join\n  ctp_file natural join \n  file_patient natural join \n  file_series\nwhere\n  project_name = ? and\n  visibility is not null\ngroup by collection, site, patient_id, user_name, time, reason_for\norder by time, collection, site, patient_id	{collection}	{collection,site,patient_id,user_name,time,reason_for,count}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files,show_hidden}	posda_files	Show Received before date by collection, site
StudyHierarchyByStudyUID	select distinct\n  study_instance_uid, study_description,\n  series_instance_uid, series_description,\n  modality,\n  count(distinct sop_instance_uid) as number_of_sops\nfrom\n  file_study natural join ctp_file natural join file_series natural join file_sop_common\nwhere study_instance_uid = ? and visibility is null\ngroup by\n  study_instance_uid, study_description,\n  series_instance_uid, series_description, modality	{study_instance_uid}	{study_instance_uid,study_description,series_instance_uid,series_description,modality,number_of_sops}	{by_study,Hierarchy}	posda_files	Show List of Study Descriptions, Series UID, Series Descriptions, and Count of SOPS for a given Study Instance UID
DistinctPatientStudySeriesByCollectionDateRange	select distinct\n  patient_id, \n  study_instance_uid,\n  series_instance_uid, \n  dicom_file_type,\n  modality, \n  count(distinct file_id) as num_files\nfrom\n  ctp_file\n  natural join dicom_file\n  natural join file_study\n  natural join file_series\n  natural join file_patient\n  natural join file_import\n  natural join import_event\nwhere\n  project_name = ? and\n  visibility is null and\n  import_time > ?\n  and import_time < ?\ngroup by\n  patient_id, \n  study_instance_uid,\n  series_instance_uid,\n  dicom_file_type,\n  modality\n  	{collection,from,to}	{patient_id,study_instance_uid,series_instance_uid,dicom_file_type,modality,num_files}	{by_collection,find_series,search_series,send_series}	posda_files	Get Series in A Collection\n
DispositonsSimple	select \n  distinct \n  element_seen_id as id, \n  element_sig_pattern,\n  vr,\n  tag_name,\n  private_disposition as disposition\nfrom\n  element_seen\nwhere\n  is_private\n	{}	{id,element_sig_pattern,vr,tag_name,disposition}	{tag_usage,simple_phi_maint,phi_maint}	posda_phi_simple	Private tags with no disposition with values in phi_simple
GetDupContourCountsExtendedByCollection	select\n  project_name as collection,\n  site_name as site,\n  patient_id,\n  file_id,\n  num_dup_contours\nfrom (\n  select \n    distinct file_id, count(*) as num_dup_contours\n  from\n    file_roi_image_linkage \n  where \n    contour_digest in (\n    select contour_digest\n    from (\n      select \n        distinct contour_digest, count(*)\n      from\n        file_roi_image_linkage group by contour_digest\n    ) as foo\n    where count > 1\n  ) group by file_id \n) foo join ctp_file using (file_id) join file_patient using(file_id)\nwhere project_name = ? and visibility is null\norder by num_dup_contours desc	{collection}	{collection,site,patient_id,file_id,num_dup_contours}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
ShowFilesHiddenByUserDateRange	select \n  distinct project_name as collection,\n  site_name as site,\n  patient_id,\n  study_instance_uid,\n  series_instance_uid,\n  reason_for as reason,\n  prior_visibility as before,\n  new_visibility as after,\n  min(time_of_change) as earliest,\n  max(time_of_change) as latest,\n  count(distinct file_id) as num_files\nfrom \n  file_visibility_change natural join\n  file_patient natural join\n  file_study natural join\n  file_series natural join \n  ctp_file\nwhere\n  user_name = ? and\n  time_of_change > ? and time_of_change < ?\ngroup by\n   collection, site, \n   patient_id, study_instance_uid,\n   series_instance_uid, reason, before, after\norder by\n  patient_id, study_instance_uid, series_instance_uid	{user,from,to}	{collection,site,patient_id,study_instance_uid,series_instance_uid,reason,before,after,num_files,earliest,latest}	{find_series,equivalence_classes,consistency,visual_review_results,show_hidden}	posda_files	Show Files Hidden By User Date Range
FilesByCollectionSiteWithVisibility	select\n  distinct\n  file_id,\n  project_name as collection,\n  site_name as site,\n  patient_id,\n  series_instance_uid,\n  sop_instance_uid,\n  file_id,\n  visibility\nfrom\n  ctp_file\n  join file_patient using(file_id)\n  join file_series using(file_id)\n  join file_sop_common using(file_id)\nwhere \n  project_name = ?	{collection}	{collection,site,patient_id,series_instance_uid,sop_instance_uid,file_id,visibility}	{hide_files}	posda_files	Get List of files for Collection, Site with visibility
FindTagsInQueries	select\n  distinct tag from (\n  select name, unnest(tags) as tag\n  from queries) as foo\norder by tag	{}	{tag}	{meta,test,hello,query_tags}	posda_queries	Find all queries matching tag
GetSsVolumeReferencingUnknownImagesByCollection	select \n  project_name as collection, \n  site_name as site, patient_id, \n  file_id \nfrom \n  ctp_file natural join file_patient \nwhere file_id in (\n   select\n    distinct file_id from ss_volume v \n    join ss_for using(ss_for_id) \n    join file_structure_set using (structure_set_id) \n  where \n     not exists (\n       select file_id \n       from file_sop_common s \n       where s.sop_instance_uid = v.sop_instance\n  )\n)\nand project_name = ?\nand visibility is null\norder by collection, site, patient_id	{collection}	{collection,site,patient_id,file_id}	{"Structure Sets",sops,LinkageChecks,struct_linkages}	posda_files	Get list of plan which reference unknown SOPs\n\n
DupSopsByCollectionDateRange	select\n  distinct collection, site, subj_id, \n  sop_instance_uid,\n  count(distinct file_id) as num_files\nfrom (\n  select\n    distinct project_name as collection,\n    site_name as site, patient_id as subj_id,\n    study_instance_uid, series_instance_uid,\n    sop_instance_uid,\n    file_id\n  from\n    ctp_file natural join file_sop_common\n    natural join file_patient natural join file_study natural join file_series\n  where\n    sop_instance_uid in (\n      select distinct sop_instance_uid \n      from (\n        select distinct sop_instance_uid, count(distinct file_id)\n        from file_sop_common natural join ctp_file\n        where visibility is null and sop_instance_uid in (\n          select distinct sop_instance_uid\n          from file_sop_common natural join ctp_file\n            join file_import using(file_id) \n            join import_event using(import_event_id)\n          where project_name = ?  and\n             visibility is null and import_time > ?\n              and import_time < ?\n        ) group by sop_instance_uid\n      ) as foo \n      where count > 1\n    )\n    and visibility is null\n  ) as foo\ngroup by collection, site, subj_id, sop_instance_uid\n\n	{collection,from,to}	{collection,site,subj_id,sop_instance_uid,num_files}	{duplicates,dup_sops,hide_dup_sops}	posda_files	Return a count of duplicate SOP Instance UIDs\n
ByDistinguishedDigest	select\n  distinct project_name as collection,\n  site_name as site,\n  patient_id as subject,\n  series_instance_uid, \n  count(distinct sop_instance_uid) as num_sops\nfrom \n  ctp_file natural join\n  file_patient natural join\n  file_sop_common natural join\n  file_series\nwhere file_id in (\n  select \n    file_id\n  from\n    file_image\n    join image using(image_id)\n    join unique_pixel_data using(unique_pixel_data_id)\n  where digest = ?\n  ) and visibility is null \ngroup by \n  collection,\n  site,\n  series_instance_uid,\n  subject\norder by\n  collection,\n  site,\n  subject	{pixel_digest}	{collection,site,subject,series_instance_uid,num_sops}	{duplicates,distinguished_digest}	posda_files	Return a count of duplicate SOP Instance UIDs\n
ShowAllHideEventsByCollectionSiteAlt	select\n distinct\n  user_name,\n  date_trunc('hour',time_of_change) as hour_of_change,\n  prior_visibility,\n  new_visibility,\n  reason_for,\n  count(distinct file_id) as num_files\nfrom\n   file_visibility_change \nwhere file_id in (\n  select file_id \n  from ctp_file \n  where project_name = ? and site_name = ?\n  and visibility = 'hidden' \n)\ngroup by user_name, hour_of_change, prior_visibility, new_visibility, reason_for	{collection,site}	{user_name,hour_of_change,prior_visibility,new_visibility,reason_for,num_files}	{show_hidden}	posda_files	Show All Hide Events by Collection, Site
SeriesReport	select \n  file_id, sop_instance_uid, modality, cast(instance_number as int) inst_num, iop, ipp\nfrom \n  file_series natural join file_sop_common \n  left join file_image_geometry using(file_id) \n  left join image_geometry using(image_geometry_id)\nwhere file_id in (\n  select \n  file_id from file_series natural join ctp_file\n  where series_instance_uid = ?\n    and visibility is null\n) order by inst_num;	{series_instance_uid}	{file_id,modality,inst_num,iop,ipp,sop_instance_uid}	{by_series_instance_uid,duplicates,posda_files,sops,series_report}	posda_files	Get Distinct SOPs in Series with number files\nOnly visible filess\n
SimplePhiReportAllRelevantPrivateOnlyNew	select \n  distinct '<' || element_sig_pattern || '>'  as element, length(value) as val_length,\n  vr, value, tag_name as description, private_disposition as disp, count(*) as num_series\nfrom element_value_occurance natural join element_seen natural join value_seen\nwhere \n  phi_scan_instance_id = ? and is_private and private_disposition not in ('d', 'na', 'h', 'o', 'oi')\ngroup by element_sig_pattern, vr, value, val_length, description, disp\norder by vr, element, val_length	{scan_id}	{element,vr,value,description,disp,num_series}	{tag_usage,simple_phi}	posda_phi_simple	Status of PHI scans\n
DistinguishedDigests	select\n   pixel_digest as distinguished_pixel_digest,\n   type_of_pixel_data,\n   sample_per_pixel,\n   number_of_frames,\n   pixel_rows,\n   pixel_columns,\n   bits_stored,\n   bits_allocated,\n   high_bit,\n   pixel_mask,\n   num_distinct_pixel_values,\n   pixel_value,\n   num_occurances\nfrom \n  distinguished_pixel_digests natural join\n  distinguished_pixel_digest_pixel_value	{}	{distinguished_pixel_digest,type_of_pixel_data,sample_per_pixel,number_of_frames,pixel_rows,pixel_columns,bits_stored,bits_allocated,high_bit,pixel_mask,num_distinct_values,pixel_value,num_occurances}	{duplicates,distinguished_digest}	posda_files	show series with distinguished digests and counts
FindPotentialDistinguishedSops	select \n  distinct project_name as collection,\n  site_name as site, \n  patient_id, \n  image_id,\n  count(*)\nfrom\n  ctp_file\n  natural join file_patient\n  natural join file_image\nwhere\n  file_id in \n  (select \n    distinct file_id \n  from\n    file_image \n  where\n    image_id in\n    (select\n       image_id from \n       (select\n         distinct image_id, count(distinct file_id) \n       from\n         file_image \n       group by image_id\n       ) as foo\n     where count > 1000\n  )\n) group by collection, site, patient_id, image_id\norder by collection, site, image_id, patient_id\n\n	{}	{collection,site,patient_id,image_id,count}	{duplicates,distinguished_digest}	posda_files	Return a count of duplicate SOP Instance UIDs\n
FilesVisibilityByCollectionSitePatient	select\n  distinct project_name as collection,\n  site_name as site,\n  patient_id, file_id, visibility\nfrom\n  ctp_file natural join file_patient\nwhere\n  project_name = ? and\n  site_name = ? and\n  patient_id = ?\norder by collection, site, patient_id\n\n	{collection,site,patient_id}	{collection,site,patient_id,file_id,visibility}	{duplicates,dup_sops,hide_dup_sops,sops_different_series}	posda_files	Return a count of duplicate SOP Instance UIDs\n
FilesByCollectionSitePatientVisibility	select\n  distinct project_name as collection,\n  site_name as site,\n  patient_id, file_id, visibility\nfrom\n  ctp_file natural join file_patient\nwhere\n  project_name = ? and\n  site_name = ? and\n  patient_id = ? and visibility = ?\norder by collection, site, patient_id\n\n	{collection,site,patient_id,visibility}	{collection,site,patient_id,file_id,visibility}	{duplicates,dup_sops,hide_dup_sops,sops_different_series}	posda_files	Return a count of duplicate SOP Instance UIDs\n
VisibleFilesByCollectionSitePatient	select\n  distinct project_name as collection,\n  site_name as site,\n  patient_id, file_id, visibility\nfrom\n  ctp_file natural join file_patient\nwhere\n  project_name = ? and\n  site_name = ? and\n  patient_id = ? and\n  visibility is null\norder by collection, site, patient_id\n\n	{collection,site,patient_id}	{collection,site,patient_id,file_id,visibility}	{duplicates,dup_sops,hide_dup_sops,sops_different_series}	posda_files	Return a count of duplicate SOP Instance UIDs\n
RTSTRUCTWithBadModality	select distinct\n  project_name as collection,\n  site_name as site, \n  patient_id,\n  series_instance_uid,\n  modality,\n  dicom_file_type,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join ctp_file natural join file_patient\n  natural join dicom_file\nwhere \n  dicom_file_type = 'RT Structure Set Storage' and \n  visibility is null and\n  modality != 'RTSTRUCT'\ngroup by\n  collection, site, patient_id, series_instance_uid, modality, dicom_file_type\norder by\n  collection, site, patient_id\n	{}	{collection,site,patient_id,series_instance_uid,modality,dicom_file_type,num_files}	{by_series,consistency,series_consistency}	posda_files	Check a Series for Consistency\n
CtWithBadModality	select distinct\n  project_name as collection,\n  site_name as site, \n  patient_id,\n  series_instance_uid,\n  modality,\n  dicom_file_type,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join ctp_file natural join file_patient\n  natural join dicom_file\nwhere \n  dicom_file_type = 'CT Image Storage' and \n  visibility is null and\n  modality != 'CT'\ngroup by\n  collection, site, patient_id, series_instance_uid, modality, dicom_file_type\norder by\n  collection, site, patient_id\n	{}	{collection,site,patient_id,series_instance_uid,modality,dicom_file_type,num_files}	{by_series,consistency,series_consistency}	posda_files	Check a Series for Consistency\n
MRWithBadModality	select distinct\n  project_name as collection,\n  site_name as site, \n  patient_id,\n  series_instance_uid,\n  modality,\n  dicom_file_type,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join ctp_file natural join file_patient\n  natural join dicom_file\nwhere \n  dicom_file_type = 'MR Image Storage' and \n  visibility is null and\n  modality != 'MR'\ngroup by\n  collection, site, patient_id, series_instance_uid, modality, dicom_file_type\norder by\n  collection, site, patient_id\n	{}	{collection,site,patient_id,series_instance_uid,modality,dicom_file_type,num_files}	{by_series,consistency,series_consistency}	posda_files	Check a Series for Consistency\n
PTWithBadModality	select distinct\n  project_name as collection,\n  site_name as site, \n  patient_id,\n  series_instance_uid,\n  modality,\n  dicom_file_type,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join ctp_file natural join file_patient\n  natural join dicom_file\nwhere \n  dicom_file_type = 'Positron Emission Tomography Image Storage' and \n  visibility is null and\n  modality != 'PT'\ngroup by\n  collection, site, patient_id, series_instance_uid, modality, dicom_file_type\norder by\n  collection, site, patient_id\n	{}	{collection,site,patient_id,series_instance_uid,modality,dicom_file_type,num_files}	{by_series,consistency,series_consistency}	posda_files	Check a Series for Consistency\n
RTDOSEWithBadModality	select distinct\n  project_name as collection,\n  site_name as site, \n  patient_id,\n  series_instance_uid,\n  modality,\n  dicom_file_type,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join ctp_file natural join file_patient\n  natural join dicom_file\nwhere \n  dicom_file_type = 'RT Dose Storage' and \n  visibility is null and\n  modality != 'RTDOSE'\ngroup by\n  collection, site, patient_id, series_instance_uid, modality, dicom_file_type\norder by\n  collection, site, patient_id\n	{}	{collection,site,patient_id,series_instance_uid,modality,dicom_file_type,num_files}	{by_series,consistency,series_consistency}	posda_files	Check a Series for Consistency\n
RTPLANWithBadModality	select distinct\n  project_name as collection,\n  site_name as site, \n  patient_id,\n  series_instance_uid,\n  modality,\n  dicom_file_type,\n  count(distinct file_id) as num_files\nfrom\n  file_series natural join ctp_file natural join file_patient\n  natural join dicom_file\nwhere \n  dicom_file_type = 'RT Plan Storage' and \n  visibility is null and\n  modality != 'RTPLAN'\ngroup by\n  collection, site, patient_id, series_instance_uid, modality, dicom_file_type\norder by\n  collection, site, patient_id\n	{}	{collection,site,patient_id,series_instance_uid,modality,dicom_file_type,num_files}	{by_series,consistency,series_consistency}	posda_files	Check a Series for Consistency\n
VisibilityChangeEventsByCollectionForAllFiles	select\n  distinct project_name as collection, \n  site_name as site,\n  user_name, \n  date_trunc('hour',time_of_change) as time, \n  reason_for, count(distinct file_id)\nfrom\n  file_visibility_change natural join\n  ctp_file\nwhere\n  project_name = ?\ngroup by collection, site, user_name, time, reason_for\norder by time, collection, site	{collection}	{collection,site,user_name,time,reason_for,count}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files,show_hidden}	posda_files	Show Received before date by collection, site
VisibilityChangeEventsByCollectionDateRangeForHiddenFilesWithSeries	select\n  distinct project_name as collection, \n  site_name as site, patient_id,\n  user_name, \n  date_trunc('hour',time_of_change) as time, \n  reason_for, series_instance_uid, count(*)\nfrom\n  file_visibility_change natural join\n  ctp_file natural join \n  file_patient natural join \n  file_series\nwhere\n  project_name = ? and\n  visibility is not null and\n  time_of_change > ? and time_of_change < ?\ngroup by \n  collection, site, patient_id, user_name, \n  time, reason_for, series_instance_uid\norder by time, collection, site, patient_id, series_instance_uid	{collection,from,to}	{collection,site,patient_id,user_name,time,series_instance_uid,reason_for,count}	{find_series,equivalence_classes,consistency,visual_review_results,hide_files,show_hidden}	posda_files	Show Received before date by collection, site
\.


--
-- Data for Name: query_invoked_by_dbif; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY query_invoked_by_dbif (query_invoked_by_dbif_id, query_name, invoking_user, query_start_time, query_end_time, number_of_rows) FROM stdin;
1	ListOfCollectionsAndSites	quasarj	2017-05-25 15:48:49-05	2017-05-25 15:49:17-05	78
2	RoundInfoLastCompleteRound	bbennett	2017-05-25 15:56:32-05	2017-05-25 15:56:33-05	1
3	CountsByCollectionDateRangePlus	bbennett	2017-05-25 15:57:49-05	2017-05-25 16:02:04-05	1670
4	ListOfQueriesPerformed	bbennett	2017-05-25 16:14:54-05	2017-05-25 16:14:55-05	3
5	ListOfQueriesPerformed	bbennett	2017-05-25 16:15:39-05	2017-05-25 16:15:39-05	4
6	ListOfQueriesPerformed	bbennett	2017-05-25 16:15:57-05	2017-05-25 16:15:57-05	5
7	ListOfQueriesPerformed	bbennett	2017-05-25 16:26:44-05	2017-05-25 16:26:44-05	6
8	QueryArgsByQueryId	bbennett	2017-05-25 16:30:58-05	2017-05-25 16:30:58-05	3
9	ListOfQueriesPerformed	bbennett	2017-05-25 16:33:53-05	2017-05-25 16:33:53-05	0
10	ListOfQueriesPerformedByUser	bbennett	2017-05-25 16:34:17-05	2017-05-25 16:34:17-05	9
11	ListOfQueriesPerformed	bbennett	2017-05-25 16:34:33-05	2017-05-25 16:34:33-05	0
12	ListOfQueriesPerformed	bbennett	2017-05-25 16:34:55-05	2017-05-25 16:34:55-05	11
13	ListOfQueriesPerformedByUser	bbennett	2017-05-25 16:35:32-05	2017-05-25 16:35:32-05	11
14	ListOfQueriesPerformedByQueryName	bbennett	2017-05-25 16:38:30-05	2017-05-25 16:38:30-05	7
15	ListOfQueriesPerformedByQueryName	bbennett	2017-05-25 16:40:05-05	2017-05-25 16:40:05-05	1
16	QueryArgsByQueryId	bbennett	2017-05-25 16:40:24-05	2017-05-25 16:40:25-05	0
17	ListOfQueriesPerformed	bbennett	2017-05-25 16:40:40-05	2017-05-25 16:40:40-05	16
18	QueryArgsByQueryId	bbennett	2017-05-25 16:40:59-05	2017-05-25 16:40:59-05	1
19	CountsByCollectionDateRange	tracyn	2017-05-25 16:44:17-05	2017-05-25 16:44:45-05	9
20	ListOfQueriesPerformedByDate	bbennett	2017-05-25 16:46:39-05	2017-05-25 16:46:39-05	19
21	ListOfQueriesPerformedByDate	bbennett	2017-05-25 16:47:27-05	2017-05-25 16:47:27-05	20
22	QueryArgsByQueryId	bbennett	2017-05-25 16:47:41-05	2017-05-25 16:47:41-05	3
23	ListOfQueriesPerformedByUserByDate	bbennett	2017-05-25 16:50:59-05	2017-05-25 16:50:59-05	20
24	CountsByCollectionDateRange	tracyn	2017-05-25 16:51:29-05	2017-05-25 16:51:38-05	0
25	CountsByCollectionDateRange	tracyn	2017-05-25 16:52:09-05	2017-05-25 16:52:18-05	1
26	FindInconsistentSeries	tracyn	2017-05-25 17:36:09-05	2017-05-25 17:36:09-05	0
27	FindInconsistentStudy	tracyn	2017-05-25 17:37:05-05	2017-05-25 17:37:05-05	0
28	SubjectsWithDupSopsByCollection	tracyn	2017-05-25 17:44:56-05	2017-05-25 17:45:01-05	0
29	DistinctSeriesByCollectionSite	tracyn	2017-05-25 17:45:55-05	2017-05-25 17:45:55-05	0
30	DistinctSeriesByCollection	tracyn	2017-05-25 17:46:40-05	2017-05-25 17:46:40-05	0
31	DistinctSeriesByCollection	tracyn	2017-05-25 17:46:54-05	2017-05-25 17:46:54-05	0
32	FindInconsistentSeries	tracyn	2017-05-25 17:48:55-05	2017-05-25 17:48:55-05	0
33	FindInconsistentStudy	tracyn	2017-05-25 17:49:10-05	2017-05-25 17:49:10-05	17
34	StudyConsistency	tracyn	2017-05-25 17:49:41-05	2017-05-25 17:49:42-05	2
35	StudyConsistency	tracyn	2017-05-25 17:47:42-05	2017-05-25 17:53:08-05	19
36	FindInconsistentStudy	tracyn	2017-05-25 18:09:01-05	2017-05-25 18:09:01-05	17
37	FindInconsistentSeries	tracyn	2017-05-25 18:09:30-05	2017-05-25 18:09:30-05	0
38	FindInconsistentStudy	tracyn	2017-05-25 18:09:48-05	2017-05-25 18:09:48-05	17
39	StudyHierarchyByStudyUID	tracyn	2017-05-25 18:11:37-05	2017-05-25 18:11:37-05	3
40	StudyHierarchyByStudyUID	tracyn	2017-05-25 18:12:27-05	2017-05-25 18:12:28-05	3
41	StudyHierarchyByStudyUID	tracyn	2017-05-25 18:15:09-05	2017-05-25 18:15:09-05	3
42	StudyHierarchyByStudyUID	tracyn	2017-05-25 18:15:39-05	2017-05-25 18:15:40-05	3
43	StudyHierarchyByStudyUID	tracyn	2017-05-25 18:16:08-05	2017-05-25 18:16:09-05	3
44	StudyHierarchyByStudyUID	tracyn	2017-05-25 18:16:37-05	2017-05-25 18:16:37-05	3
45	StudyHierarchyByStudyUID	tracyn	2017-05-25 18:17:17-05	2017-05-25 18:17:17-05	3
46	FindInconsistentStudy	tracyn	2017-05-25 18:19:05-05	2017-05-25 18:19:05-05	17
47	StudyHierarchyByStudyUID	tracyn	2017-05-25 18:19:21-05	2017-05-25 18:19:22-05	3
48	ListOfAvailableQueries	bbennett	2017-05-26 06:47:59-05	2017-05-26 06:47:59-05	574
49	ListOfAvailableQueries	bbennett	2017-05-26 06:49:01-05	2017-05-26 06:49:01-05	574
50	ListOfAvailableQueries	bbennett	2017-05-26 06:51:56-05	2017-05-26 06:51:56-05	1367
51	ListOfAvailableQueries	bbennett	2017-05-26 06:52:36-05	2017-05-26 06:52:36-05	1367
52	ListOfAvailableQueries	bbennett	2017-05-26 06:54:00-05	2017-05-26 06:54:00-05	1367
53	ListOfAvailableQueries	bbennett	2017-05-26 06:55:25-05	2017-05-26 06:55:25-05	1367
54	ListOfAvailableQueriesByTag	bbennett	2017-05-26 06:58:39-05	2017-05-26 06:58:39-05	0
55	ListOfAvailableQueriesByTag	bbennett	2017-05-26 06:58:54-05	2017-05-26 06:58:54-05	4
56	ListOfAvailableQueriesByNameLike	bbennett	2017-05-26 06:59:51-05	2017-05-26 06:59:51-05	52
57	ListOfAvailableQueriesByTagLike	bbennett	2017-05-26 07:01:12-05	2017-05-26 07:01:12-05	4
58	ListOfAvailableQueriesByTagLike	bbennett	2017-05-26 07:01:27-05	2017-05-26 07:01:27-05	0
59	ListOfAvailableQueriesByTagLike	bbennett	2017-05-26 07:02:04-05	2017-05-26 07:02:04-05	0
60	ListOfAvailableQueriesByTagLike	bbennett	2017-05-26 07:02:26-05	2017-05-26 07:02:26-05	10
61	QueryByName	bbennett	2017-05-26 07:05:04-05	2017-05-26 07:05:04-05	1
62	QueryByName	bbennett	2017-05-26 07:06:27-05	2017-05-26 07:06:27-05	1
63	QueryByName	bbennett	2017-05-26 07:06:59-05	2017-05-26 07:06:59-05	1
64	QueryByName	bbennett	2017-05-26 07:07:57-05	2017-05-26 07:07:57-05	1
65	ListOfAvailableQueriesByTagLike	bbennett	2017-05-26 07:09:33-05	2017-05-26 07:09:33-05	0
66	ListOfAvailableQueriesByTagLike	bbennett	2017-05-26 07:11:00-05	2017-05-26 07:11:00-05	4
67	QueryByName	bbennett	2017-05-26 07:11:52-05	2017-05-26 07:11:52-05	1
68	ListOfAvailableQueriesByNameLike	bbennett	2017-05-26 07:12:34-05	2017-05-26 07:12:34-05	13
69	QueryByName	bbennett	2017-05-26 07:12:57-05	2017-05-26 07:12:57-05	1
70	ListOfAvailableQueries	bbennett	2017-05-26 07:16:48-05	2017-05-26 07:16:48-05	1378
71	FindTagsInQuery	bbennett	2017-05-26 07:17:39-05	2017-05-26 07:17:39-05	4
72	FindTagsInQuery	bbennett	2017-05-26 07:19:22-05	2017-05-26 07:19:22-05	4
73	FindTagsInQuery	bbennett	2017-05-26 07:23:10-05	2017-05-26 07:23:10-05	4
74	DeleteFirstTagFromQuery	bbennett	2017-05-26 07:23:19-05	2017-05-26 07:23:20-05	0
75	FindTagsInQuery	bbennett	2017-05-26 07:23:26-05	2017-05-26 07:23:26-05	4
76	DeleteFirstTagFromQuery	bbennett	2017-05-26 07:24:19-05	2017-05-26 07:24:19-05	0
77	AddTagToQuery	bbennett	2017-05-26 07:24:48-05	2017-05-26 07:24:48-05	1
78	FindTagsInQuery	bbennett	2017-05-26 07:25:06-05	2017-05-26 07:25:06-05	5
79	DeleteLastTagFromQuery	bbennett	2017-05-26 07:25:16-05	2017-05-26 07:25:16-05	1
80	FindTagsInQuery	bbennett	2017-05-26 07:25:25-05	2017-05-26 07:25:25-05	4
81	ListOfAvailableQueries	bbennett	2017-05-26 07:28:12-05	2017-05-26 07:28:12-05	579
82	ListOfAvailableQueriesByNameLike	bbennett	2017-05-26 07:30:34-05	2017-05-26 07:30:34-05	6
83	PrependTagToQuery	bbennett	2017-05-26 07:34:11-05	2017-05-26 07:34:11-05	1
84	FindTagsInQuery	bbennett	2017-05-26 07:34:18-05	2017-05-26 07:34:18-05	5
85	DeleteLastTagFromQuery	bbennett	2017-05-26 07:34:35-05	2017-05-26 07:34:35-05	1
86	FindTagsInQuery	bbennett	2017-05-26 07:34:44-05	2017-05-26 07:34:44-05	4
87	PrependTagToQuery	bbennett	2017-05-26 07:37:43-05	2017-05-26 07:37:43-05	1
88	FindTagsInQuery	bbennett	2017-05-26 07:37:49-05	2017-05-26 07:37:49-05	5
89	DeleteFirstTagFromQuery	bbennett	2017-05-26 07:38:02-05	2017-05-26 07:38:02-05	0
90	DeleteFirstTagFromQuery	bbennett	2017-05-26 07:39:09-05	2017-05-26 07:39:09-05	1
91	FindTagsInQuery	bbennett	2017-05-26 07:39:18-05	2017-05-26 07:39:18-05	4
92	ListOfAvailableQueriesBySchema	bbennett	2017-05-26 08:04:33-05	2017-05-26 08:04:33-05	0
93	ListOfAvailableQueriesBySchema	bbennett	2017-05-26 08:04:50-05	2017-05-26 08:04:50-05	25
94	ListOfAvailableQueriesBySchema	bbennett	2017-05-26 08:05:16-05	2017-05-26 08:05:16-05	25
95	ListOfSchemas	bbennett	2017-05-26 08:06:24-05	2017-05-26 08:06:25-05	13
96	ListOfAvailableQueriesBySchema	bbennett	2017-05-26 08:06:39-05	2017-05-26 08:06:39-05	45
97	ListOfAvailableQueries	bbennett	2017-05-26 08:07:35-05	2017-05-26 08:07:35-05	582
98	ListOfAvailableQueriesBySchema	bbennett	2017-05-26 08:08:39-05	2017-05-26 08:08:39-05	345
99	ListOfAvailableQueriesByNameLike	bbennett	2017-05-26 08:11:57-05	2017-05-26 08:11:57-05	6
100	ListOfAvailableQueriesForDescEdit	bbennett	2017-05-26 08:13:53-05	2017-05-26 08:13:53-05	583
101	ListOfAvailableQueriesForDescEdit	bbennett	2017-05-26 08:18:28-05	2017-05-26 08:18:28-05	583
102	ListOfAvailableQueriesForDescEditBySchema	bbennett	2017-05-26 08:22:02-05	2017-05-26 08:22:02-05	345
103	ListOfAvailableQueriesByTagLike	bbennett	2017-05-26 08:25:05-05	2017-05-26 08:25:05-05	157
104	ListOfAvailableQueriesByTagLike	bbennett	2017-05-26 08:28:11-05	2017-05-26 08:28:11-05	157
105	ListOfAvailableQueriesByTagLike	bbennett	2017-05-26 08:29:15-05	2017-05-26 08:29:15-05	157
106	ListOfAvailableQueriesByTagLike	bbennett	2017-05-26 08:29:36-05	2017-05-26 08:29:36-05	55
107	ActiveQueriesOld	bbennett	2017-05-26 08:31:47-05	2017-05-26 08:31:47-05	46
108	FindInconsistentStudy	bbennett	2017-05-26 09:03:09-05	2017-05-26 09:03:09-05	17
109	StudyConsistency	bbennett	2017-05-26 09:03:22-05	2017-05-26 09:03:30-05	2
110	StudyHierarchyByStudyUID	bbennett	2017-05-26 09:04:04-05	2017-05-26 09:04:05-05	3
111	StudyHierarchyByStudyUID	bbennett	2017-05-26 09:05:18-05	2017-05-26 09:05:19-05	3
112	StudyHierarchyByStudyUID	bbennett	2017-05-26 09:05:57-05	2017-05-26 09:05:57-05	3
113	StudyConsistency	bbennett	2017-05-26 09:09:29-05	2017-05-26 09:09:29-05	2
114	StudyConsistency	tracyn	2017-05-26 09:11:38-05	2017-05-26 09:11:39-05	2
115	FindInconsistentStudy	tracyn	2017-05-26 09:12:54-05	2017-05-26 09:12:54-05	17
116	StudyHierarchyByStudyUID	tracyn	2017-05-26 09:13:05-05	2017-05-26 09:13:06-05	3
117	StudyHierarchyByStudyUID	tracyn	2017-05-26 09:13:45-05	2017-05-26 09:13:46-05	3
118	StudyHierarchyByStudyUID	tracyn	2017-05-26 09:14:16-05	2017-05-26 09:14:17-05	3
119	StudyHierarchyByStudyUID	tracyn	2017-05-26 09:14:27-05	2017-05-26 09:14:27-05	3
120	StudyHierarchyByStudyUID	tracyn	2017-05-26 09:15:02-05	2017-05-26 09:15:02-05	3
121	StudyHierarchyByStudyUID	tracyn	2017-05-26 09:16:20-05	2017-05-26 09:16:21-05	4
122	StudyHierarchyByStudyUID	tracyn	2017-05-26 09:16:55-05	2017-05-26 09:16:56-05	3
123	StudyHierarchyByStudyUID	tracyn	2017-05-26 09:17:39-05	2017-05-26 09:17:40-05	3
124	StudyHierarchyByStudyUID	tracyn	2017-05-26 09:18:10-05	2017-05-26 09:18:11-05	3
125	StudyHierarchyByStudyUID	tracyn	2017-05-26 09:18:56-05	2017-05-26 09:18:56-05	3
126	StudyHierarchyByStudyUID	tracyn	2017-05-26 09:19:28-05	2017-05-26 09:19:28-05	3
127	CountsByCollectionDateRange	tracyn	2017-05-26 09:21:20-05	2017-05-26 09:22:12-05	51
128	ListOfQueriesPerformedByUser	bbennett	2017-05-26 09:23:47-05	2017-05-26 09:23:47-05	39
129	QueryArgsByQueryId	bbennett	2017-05-26 09:24:09-05	2017-05-26 09:24:09-05	3
130	ListOfQueriesPerformedByUser	bbennett	2017-05-26 09:24:23-05	2017-05-26 09:24:23-05	39
131	FilesAndLoadTimesInSeries	bbennett	2017-05-26 09:28:37-05	2017-05-26 09:28:38-05	3
132	GetDupContourCounts	bbennett	2017-05-26 09:36:35-05	2017-05-26 09:36:39-05	885
133	GetDupContourCountsExtended	bbennett	2017-05-26 09:37:00-05	2017-05-26 09:37:08-05	900
134	GetDupContourCountsExtendedByCollection	bbennett	2017-05-26 09:39:39-05	2017-05-26 09:39:42-05	4
135	GetDupContourCountsExtendedByCollection	bbennett	2017-05-26 09:41:25-05	2017-05-26 09:41:28-05	2
136	CountsByCollectionDateRange	bbennett	2017-05-26 09:50:07-05	2017-05-26 09:50:08-05	51
137	GetSeriesWithImageByCollectionSite	bbennett	2017-05-26 09:52:18-05	2017-05-26 09:52:19-05	17
138	GetSeriesWithImageByCollectionSite	tracyn	2017-05-26 09:53:39-05	2017-05-26 09:53:39-05	17
139	GetSeriesWithImageAndNoEquivalenceClassByCollectionSiteDateRange	bbennett	2017-05-26 09:56:57-05	2017-05-26 09:57:04-05	2
140	GetSeriesWithImageByCollection	bbennett	2017-05-26 09:57:14-05	2017-05-26 09:57:14-05	17
141	SeriesVisualReviewResultsByCollectionSiteSummary	bbennett	2017-05-26 10:01:47-05	2017-05-26 10:01:47-05	2
142	SeriesVisualReviewResultsByCollectionSiteSummary	bbennett	2017-05-26 10:03:58-05	2017-05-26 10:03:58-05	2
143	VisibleSeriesVisualReviewResultsByCollectionSiteStatus	bbennett	2017-05-26 10:04:38-05	2017-05-26 10:04:38-05	0
144	VisibleSeriesVisualReviewResultsByCollectionSiteStatus	bbennett	2017-05-26 10:04:49-05	2017-05-26 10:04:49-05	15
145	VisibleSeriesVisualReviewResultsByCollectionSiteStatus	bbennett	2017-05-26 10:05:34-05	2017-05-26 10:05:34-05	0
146	SeriesVisualReviewResultsByCollectionSite	bbennett	2017-05-26 10:06:48-05	2017-05-26 10:06:48-05	27
147	SeriesVisualReviewResultsByCollectionSite	bbennett	2017-05-26 10:08:15-05	2017-05-26 10:08:15-05	27
148	GetSeriesWithImageByCollection	bbennett	2017-05-26 10:17:11-05	2017-05-26 10:17:11-05	17
149	FilesAndLoadTimesInSeries	bbennett	2017-05-26 10:17:51-05	2017-05-26 10:17:51-05	246
150	FilesByCollectionSiteWithVisibility	bbennett	2017-05-26 10:44:32-05	2017-05-26 10:44:32-05	124
151	FilesByCollectionSiteWithVisibility	bbennett	2017-05-26 10:46:50-05	2017-05-26 10:46:50-05	124
152	SeriesReport	bbennett	2017-05-26 13:07:17-05	2017-05-26 13:07:17-05	246
153	FindTagsInQueries	bbennett	2017-05-26 13:31:18-05	2017-05-26 13:31:18-05	119
154	FindTagsInQueries	bbennett	2017-05-26 13:31:45-05	2017-05-26 13:31:45-05	119
155	ListOfAvailableQueriesByTag	bbennett	2017-05-26 13:32:26-05	2017-05-26 13:32:27-05	21
156	QueryByName	bbennett	2017-05-26 13:33:07-05	2017-05-26 13:33:07-05	1
157	ListOfAvailableQueries	bbennett	2017-05-26 13:39:07-05	2017-05-26 13:39:07-05	587
158	QueryByName	bbennett	2017-05-26 13:41:12-05	2017-05-26 13:41:12-05	1
159	FilesByCollectionSiteWithVisibility	tracyn	2017-05-26 14:22:58-05	2017-05-26 14:22:58-05	124
160	FilesByCollectionSiteWithVisibility	tracyn	2017-05-26 14:27:41-05	2017-05-26 14:27:41-05	124
161	FilesByCollectionSiteWithVisibility	tracyn	2017-05-26 14:28:00-05	2017-05-26 14:28:01-05	2996
162	DistinctSeriesByCollectionSite	tracyn	2017-05-26 14:42:08-05	2017-05-26 14:42:08-05	0
163	DistinctSeriesByCollectionSite	tracyn	2017-05-26 14:42:22-05	2017-05-26 14:42:22-05	51
164	PhiSimpleScanStatus	tracyn	2017-05-26 14:53:21-05	2017-05-26 14:53:21-05	17
165	SimplePhiReportAll	tracyn	2017-05-26 14:53:45-05	2017-05-26 14:54:00-05	16901
166	SimplePhiReportAll	tracyn	2017-05-26 14:53:56-05	2017-05-26 14:54:11-05	35837
167	SeriesVisualReviewResultsByCollectionSiteStatusNotGood	ksmith01	2017-05-26 15:56:01-05	2017-05-26 15:56:40-05	1420
168	ListOfCollectionsAndSites	ksmith01	2017-05-27 13:58:24-05	2017-05-27 13:58:50-05	77
169	ListOfQueriesPerformed	bbennett	2017-05-30 06:50:34-05	2017-05-30 06:50:35-05	168
170	ListOfAvailableQueriesByNameLike	bbennett	2017-05-30 06:52:03-05	2017-05-30 06:52:03-05	134
171	ListOfAvailableQueriesBySchema	bbennett	2017-05-30 06:53:34-05	2017-05-30 06:53:34-05	347
172	ListOfAvailableQueriesBySchema	bbennett	2017-05-30 06:53:49-05	2017-05-30 06:53:49-05	81
173	ListOfAvailableQueriesBySchema	bbennett	2017-05-30 06:54:01-05	2017-05-30 06:54:01-05	45
174	ListOfSchemas	bbennett	2017-05-30 06:54:16-05	2017-05-30 06:54:16-05	13
175	ListOfAvailableQueriesBySchema	bbennett	2017-05-30 06:54:31-05	2017-05-30 06:54:31-05	3
176	QueryByName	bbennett	2017-05-30 06:56:18-05	2017-05-30 06:56:18-05	1
177	ListOfAvailableQueriesForDescEdit	bbennett	2017-05-30 06:57:25-05	2017-05-30 06:57:25-05	587
178	FindDuplicatedPixelDigests	bbennett	2017-05-30 07:55:39-05	2017-05-30 07:56:14-05	15
179	FilesAndLoadTimesInSeries	bbennett	2017-05-30 09:01:38-05	2017-05-30 09:01:38-05	150
180	FindInconsistentSeries	tracyn	2017-05-30 10:17:43-05	2017-05-30 10:17:43-05	0
181	FindInconsistentSeries	tracyn	2017-05-30 10:26:11-05	2017-05-30 10:26:11-05	0
182	FindInconsistentSeries	tracyn	2017-05-30 10:26:17-05	2017-05-30 10:26:17-05	0
183	TotalsByDateRange	tracyn	2017-05-30 10:26:56-05	2017-05-30 10:33:24-05	19
184	FindInconsistentSeries	tracyn	2017-05-30 10:34:25-05	2017-05-30 10:35:25-05	0
185	FindInconsistentStudy	tracyn	2017-05-30 10:37:18-05	2017-05-30 10:37:51-05	0
186	SeriesWithDupSopsByCollectionSiteDateRange	tracyn	2017-05-30 11:01:52-05	2017-05-30 11:02:03-05	0
187	SeriesWithDupSopsByCollectionSiteDateRange	tracyn	2017-05-30 11:03:51-05	2017-05-30 11:06:37-05	480
188	DistinctSopsInSeries	tracyn	2017-05-30 11:13:25-05	2017-05-30 11:13:26-05	299
189	DistinctSopsInSeries	tracyn	2017-05-30 11:19:11-05	2017-05-30 11:19:11-05	299
190	DuplicateFilesBySop	tracyn	2017-05-30 11:19:33-05	2017-05-30 11:19:34-05	2
191	SeriesVisualReviewResultsByCollectionSiteStatusVisible	bbennett	2017-05-30 14:22:15-05	2017-05-30 14:22:35-05	0
192	CountsByCollectionDateRange	tracyn	2017-05-30 14:22:24-05	2017-05-30 14:23:10-05	127
193	SeriesVisualReviewResultsByCollectionSiteStatusVisible	bbennett	2017-05-30 14:23:02-05	2017-05-30 14:23:43-05	1030
194	SeriesVisualReviewResultsByCollectionSiteStatusVisible	bbennett	2017-05-30 14:25:03-05	2017-05-30 14:25:13-05	603
195	GetBacklogQueueSizeWithCollection	tracyn	2017-05-30 14:25:50-05	2017-05-30 14:25:51-05	0
196	GetPosdaQueueSize	tracyn	2017-05-30 14:26:05-05	2017-05-30 14:26:06-05	1
197	DupSopsByCollectionSiteDateRange	bbennett	2017-05-30 14:59:53-05	2017-05-30 15:00:10-05	0
198	ListOfCollectionsAndSites	bbennett	2017-05-30 15:00:30-05	2017-05-30 15:00:39-05	77
199	DupSopsByCollectionSiteDateRange	bbennett	2017-05-30 15:01:13-05	2017-05-30 15:04:47-05	153407
200	ListOfQueriesPerformedByDate	bbennett	2017-05-30 15:06:23-05	2017-05-30 15:06:24-05	31
201	ListOfQueriesPerformedByDate	bbennett	2017-05-30 15:08:47-05	2017-05-30 15:08:47-05	32
202	QueryArgsByQueryId	bbennett	2017-05-30 15:10:55-05	2017-05-30 15:10:55-05	4
203	DupSopsByCollectionSiteDateRange	bbennett	2017-05-30 15:08:37-05	2017-05-30 15:11:50-05	153407
204	DuplicateFilesBySop	bbennett	2017-05-30 15:16:33-05	2017-05-30 15:16:34-05	2
205	SubjectCountsDateRangeSummaryByCollectionSite	bbennett	2017-05-30 15:20:18-05	2017-05-30 15:21:08-05	3
206	CountsByCollectionDateRange	bbennett	2017-05-30 15:23:31-05	2017-05-30 15:27:20-05	1851
207	TotalsByDateRange	tracyn	2017-05-30 15:33:50-05	2017-05-30 15:40:11-05	19
208	TotalsByDateRangeAndCollection	tracyn	2017-05-30 15:44:08-05	2017-05-30 15:44:09-05	2
209	CountsByCollectionDateRange	tracyn	2017-05-30 15:45:45-05	2017-05-30 15:46:31-05	127
210	RoundInfoLastCompleteRound	bbennett	2017-05-31 06:57:34-05	2017-05-31 06:57:35-05	1
211	RoundCountsByCollection2DateRange	bbennett	2017-05-31 06:58:52-05	2017-05-31 06:58:52-05	0
212	RoundCountsByCollection2DateRange	bbennett	2017-05-31 06:59:09-05	2017-05-31 06:59:10-05	48
213	CountsByCollectionDateRangePlus	bbennett	2017-05-31 07:00:25-05	2017-05-31 07:02:03-05	49
214	ListOfQueriesPerformedByDate	bbennett	2017-05-31 07:02:19-05	2017-05-31 07:02:20-05	213
215	CountsByCollectionDateRange	bbennett	2017-05-31 07:05:09-05	2017-05-31 07:05:52-05	49
216	ListOfQueriesPerformedByDate	bbennett	2017-05-31 07:05:59-05	2017-05-31 07:05:59-05	6
217	ListOfCollectionsAndSitesLikeCollection	bbennett	2017-05-31 07:07:18-05	2017-05-31 07:07:22-05	2
218	ListOfQueriesPerformedByDate	bbennett	2017-05-31 07:07:28-05	2017-05-31 07:07:28-05	8
219	SubjectsWithDupSopsByCollection	bbennett	2017-05-31 07:08:32-05	2017-05-31 07:08:34-05	0
220	ListOfQueriesPerformedByDate	bbennett	2017-05-31 07:09:35-05	2017-05-31 07:09:35-05	10
221	SubjectsWithDupSops	bbennett	2017-05-31 07:09:20-05	2017-05-31 07:10:57-05	54
222	ListOfQueriesPerformedByDate	bbennett	2017-05-31 07:11:39-05	2017-05-31 07:11:39-05	12
223	ListOfQueriesPerformedByQueryName	bbennett	2017-05-31 07:12:26-05	2017-05-31 07:12:26-05	2
224	LongestRunningNQueries	bbennett	2017-05-31 07:20:59-05	2017-05-31 07:20:59-05	10
225	LongestRunningNQueries	bbennett	2017-05-31 07:23:00-05	2017-05-31 07:23:00-05	10
226	QueryArgsByQueryId	bbennett	2017-05-31 07:23:11-05	2017-05-31 07:23:11-05	2
227	TotalsByDateRange	bbennett	2017-05-31 07:24:57-05	2017-05-31 07:24:57-05	9
228	TotalsByDateRange	bbennett	2017-05-31 07:26:14-05	2017-05-31 07:32:52-05	19
229	TotalsByDateRange	bbennett	2017-05-31 07:34:14-05	2017-05-31 07:34:14-05	1
230	TotalsByDateRange	bbennett	2017-05-31 07:37:36-05	2017-05-31 07:37:36-05	1
231	TotalsByDateRange	bbennett	2017-05-31 07:38:00-05	2017-05-31 07:38:01-05	13
232	TotalsByDateRange	bbennett	2017-05-31 07:39:29-05	2017-05-31 07:39:29-05	13
233	TotalsByDateRange	bbennett	2017-05-31 07:39:58-05	2017-05-31 07:40:09-05	9
234	TotalsByDateRange	bbennett	2017-05-31 07:40:36-05	2017-05-31 07:44:00-05	7
235	TotalsByDateRange	bbennett	2017-05-31 07:44:39-05	2017-05-31 07:45:16-05	6
236	TotalsByDateRange	bbennett	2017-05-31 07:45:57-05	2017-05-31 07:46:12-05	5
237	TotalsByDateRange	bbennett	2017-05-31 07:46:54-05	2017-05-31 07:46:54-05	0
238	ListOfQueriesPerformedByUserByDate	bbennett	2017-05-31 07:53:11-05	2017-05-31 07:53:11-05	28
239	LongestRunningNQueries	bbennett	2017-05-31 07:55:05-05	2017-05-31 07:55:05-05	10
240	LongestRunningNQueries	bbennett	2017-05-31 07:55:52-05	2017-05-31 07:55:52-05	20
241	TotalsByDateRange	bbennett	2017-05-31 07:48:11-05	2017-05-31 07:56:12-05	24
242	LongestRunningNQueries	bbennett	2017-05-31 07:56:45-05	2017-05-31 07:56:45-05	20
243	QueryArgsByQueryId	bbennett	2017-05-31 08:07:19-05	2017-05-31 08:07:19-05	2
244	TotalsByDateRange	bbennett	2017-05-31 07:57:14-05	2017-05-31 08:07:38-05	27
245	LongestRunningNQueries	bbennett	2017-05-31 08:08:34-05	2017-05-31 08:08:34-05	20
246	QueryArgsByQueryId	bbennett	2017-05-31 08:08:49-05	2017-05-31 08:08:50-05	2
247	QueryArgsByQueryId	bbennett	2017-05-31 08:09:49-05	2017-05-31 08:09:49-05	2
248	QueryArgsByQueryId	bbennett	2017-05-31 08:10:09-05	2017-05-31 08:10:09-05	2
249	TotalsByDateRange	bbennett	2017-05-31 08:08:13-05	2017-05-31 08:10:42-05	5
250	TotalsByDateRange	bbennett	2017-05-31 08:11:17-05	2017-05-31 08:12:20-05	3
251	LongestRunningNQueries	bbennett	2017-05-31 08:12:22-05	2017-05-31 08:12:22-05	20
252	TotalsByDateRange	bbennett	2017-05-31 08:12:49-05	2017-05-31 08:13:19-05	9
253	TotalsByDateRange	bbennett	2017-05-31 08:14:08-05	2017-05-31 08:14:55-05	13
254	TotalsByDateRange	bbennett	2017-05-31 08:15:18-05	2017-05-31 08:15:45-05	9
255	TotalsByDateRange	bbennett	2017-05-31 08:16:12-05	2017-05-31 08:16:20-05	9
256	TotalsByDateRange	bbennett	2017-05-31 08:16:42-05	2017-05-31 08:17:02-05	11
257	TotalsByDateRange	bbennett	2017-05-31 08:17:34-05	2017-05-31 08:18:09-05	16
258	TotalsByDateRange	bbennett	2017-05-31 08:19:17-05	2017-05-31 08:19:19-05	4
259	TotalsByDateRange	bbennett	2017-05-31 08:19:40-05	2017-05-31 08:20:39-05	15
260	QueryByName	bbennett	2017-05-31 08:21:06-05	2017-05-31 08:21:06-05	1
261	TotalsByDateRange	bbennett	2017-05-31 08:21:27-05	2017-05-31 08:21:40-05	10
262	TotalsByDateRange	bbennett	2017-05-31 08:22:04-05	2017-05-31 08:22:56-05	6
263	TotalsByDateRange	bbennett	2017-05-31 08:24:30-05	2017-05-31 08:24:56-05	9
264	TotalsByDateRange	bbennett	2017-05-31 08:25:56-05	2017-05-31 08:25:56-05	0
265	TotalsByDateRange	bbennett	2017-05-31 08:26:29-05	2017-05-31 08:26:29-05	0
266	TotalsByDateRange	bbennett	2017-05-31 08:26:51-05	2017-05-31 08:26:51-05	0
272	TotalsByDateRange	bbennett	2017-05-31 09:55:37-05	2017-05-31 09:59:18-05	7
276	TotalsByDateRange	bbennett	2017-05-31 10:29:12-05	2017-05-31 10:29:51-05	9
280	TotalsByDateRange	bbennett	2017-05-31 10:35:42-05	2017-05-31 10:35:42-05	1
281	TotalsByDateRange	bbennett	2017-05-31 10:36:07-05	2017-05-31 10:36:07-05	0
282	TotalsByDateRange	bbennett	2017-05-31 10:37:01-05	2017-05-31 10:37:02-05	1
283	TotalsByDateRange	bbennett	2017-05-31 10:37:17-05	2017-05-31 10:37:17-05	5
267	ListOfQueriesPerformedByUserByDate	bbennett	2017-05-31 08:27:48-05	2017-05-31 08:27:48-05	57
268	QueryArgsByQueryId	bbennett	2017-05-31 08:38:25-05	2017-05-31 08:38:25-05	2
269	QueryArgsByQueryId	bbennett	2017-05-31 08:39:15-05	2017-05-31 08:39:15-05	2
270	QueryArgsByQueryId	bbennett	2017-05-31 08:40:25-05	2017-05-31 08:40:25-05	2
271	QueryArgsByQueryId	bbennett	2017-05-31 08:41:59-05	2017-05-31 08:41:59-05	2
273	ListOfQueriesPerformedByUserByDate	bbennett	2017-05-31 10:26:46-05	2017-05-31 10:26:47-05	63
274	ListOfQueriesPerformedByUserByDate	bbennett	2017-05-31 10:27:21-05	2017-05-31 10:27:21-05	64
275	QueryArgsByQueryId	bbennett	2017-05-31 10:27:34-05	2017-05-31 10:27:34-05	2
277	ListOfQueriesPerformedByUserByDate	bbennett	2017-05-31 10:30:08-05	2017-05-31 10:30:08-05	67
278	ListOfQueriesPerformedByUserByDate	bbennett	2017-05-31 10:31:36-05	2017-05-31 10:31:36-05	68
279	LongestRunningNQueries	bbennett	2017-05-31 10:33:18-05	2017-05-31 10:33:18-05	30
284	ListOfAvailableQueriesForDescEdit	bbennett	2017-05-31 10:39:49-05	2017-05-31 10:39:50-05	588
285	ListOfQueriesPerformedByUserByDate	bbennett	2017-05-31 10:46:53-05	2017-05-31 10:46:53-05	0
286	ListOfQueriesPerformedByUserByDate	bbennett	2017-05-31 10:47:08-05	2017-05-31 10:47:08-05	17
287	QueryArgsByQueryId	bbennett	2017-05-31 10:48:20-05	2017-05-31 10:48:20-05	3
288	TotalsByDateRange	bbennett	2017-05-31 10:49:34-05	2017-05-31 10:49:34-05	5
289	CountsByCollectionDateRangePlus	bbennett	2017-05-31 10:50:42-05	2017-05-31 10:52:21-05	49
290	DuplicatesInDifferentSeriesByCollectionSite	bbennett	2017-05-31 10:53:05-05	2017-05-31 10:53:05-05	0
291	DupSopsByCollectionSiteDateRange	bbennett	2017-05-31 10:53:20-05	2017-05-31 10:53:21-05	0
292	GetPlansReferencingBadSS	bbennett	2017-05-31 10:53:57-05	2017-05-31 10:53:59-05	0
293	GetSsReferencingUnknownImages	bbennett	2017-05-31 10:54:16-05	2017-05-31 10:54:44-05	1946
294	GetSsReferencingUnknownImagesByCollection	bbennett	2017-05-31 10:55:19-05	2017-05-31 10:55:39-05	0
295	GetSsReferencingKnownImagesByCollection	bbennett	2017-05-31 10:55:51-05	2017-05-31 10:56:16-05	130
296	GetSsVolumeReferencingUnknownImages	bbennett	2017-05-31 10:56:58-05	2017-05-31 10:57:11-05	1970
297	GetSsVolumeReferencingKnownImages	bbennett	2017-05-31 10:57:42-05	2017-05-31 10:57:48-05	561
298	GetSsVolumeReferencingKnownImagesByCollection	bbennett	2017-05-31 11:00:20-05	2017-05-31 11:00:22-05	205
299	GetSsVolumeReferencingUnknownImagesByCollection	bbennett	2017-05-31 11:01:24-05	2017-05-31 11:01:36-05	1
300	GetSsVolumeReferencingUnknownImagesByCollection	bbennett	2017-05-31 11:02:25-05	2017-05-31 11:02:37-05	0
301	GetSsVolumeReferencingKnownImagesByCollection	bbennett	2017-05-31 11:03:21-05	2017-05-31 11:03:23-05	130
302	GetSsVolumeReferencingKnownImagesByCollection	bbennett	2017-05-31 11:03:49-05	2017-05-31 11:03:57-05	272
303	GetSsVolumeReferencingKnownImagesByCollection	bbennett	2017-05-31 11:04:14-05	2017-05-31 11:04:17-05	272
304	GetDupContourCountsExtendedByCollection	bbennett	2017-05-31 11:04:45-05	2017-05-31 11:04:49-05	271
305	GetDupsFromSimilarDupContourCounts	bbennett	2017-05-31 11:05:01-05	2017-05-31 11:05:09-05	289
306	GetSimilarDupContourCounts	bbennett	2017-05-31 11:06:09-05	2017-05-31 11:06:15-05	2
307	FilePathByFileId	bbennett	2017-05-31 11:07:13-05	2017-05-31 11:07:13-05	1
308	FilePathByFileId	bbennett	2017-05-31 11:08:04-05	2017-05-31 11:08:04-05	1
309	GetDupContourCountsExtendedByCollection	bbennett	2017-05-31 11:09:48-05	2017-05-31 11:09:52-05	271
310	GetSimilarDupContourCounts	bbennett	2017-05-31 11:10:50-05	2017-05-31 11:10:56-05	4
311	FilePathByFileId	bbennett	2017-05-31 13:30:23-05	2017-05-31 13:30:23-05	1
312	FilePathByFileId	bbennett	2017-05-31 13:31:21-05	2017-05-31 13:31:21-05	1
313	FilePathByFileId	bbennett	2017-05-31 13:32:25-05	2017-05-31 13:32:25-05	1
314	FilePathByFileId	bbennett	2017-05-31 13:33:57-05	2017-05-31 13:33:57-05	1
315	LongestRunningNQueries	bbennett	2017-05-31 14:04:37-05	2017-05-31 14:04:37-05	50
316	ListOfQueriesPerformedByUserByDate	bbennett	2017-05-31 14:05:54-05	2017-05-31 14:05:54-05	17
317	QueryArgsByQueryId	bbennett	2017-05-31 14:06:22-05	2017-05-31 14:06:22-05	2
318	ShowAllHideEventsByCollectionSite	bbennett	2017-05-31 14:22:06-05	2017-05-31 14:22:16-05	72988
319	ShowAllHideEventsByCollectionSiteAlt	bbennett	2017-05-31 14:27:19-05	2017-05-31 14:27:21-05	72988
320	ShowAllHideEventsByCollectionSiteAlt	bbennett	2017-05-31 14:29:34-05	2017-05-31 14:29:37-05	3
321	ShowFilesHiddenByCollectionSite	bbennett	2017-05-31 14:31:46-05	2017-05-31 14:31:55-05	177
322	ShowFilesHiddenByCollectionSite	bbennett	2017-05-31 14:33:34-05	2017-05-31 14:33:39-05	177
323	ShowAllHideEventsByCollectionSiteAlt	bbennett	2017-05-31 14:36:12-05	2017-05-31 14:36:14-05	3
324	LongestRunningNQueries	bbennett	2017-06-01 07:15:52-05	2017-06-01 07:15:53-05	50
325	QueryArgsByQueryId	bbennett	2017-06-01 07:16:11-05	2017-06-01 07:16:12-05	2
326	RoundInfoLastCompleteRound	bbennett	2017-06-01 07:19:05-05	2017-06-01 07:19:06-05	1
327	SeriesReport	bbennett	2017-06-01 07:23:08-05	2017-06-01 07:23:10-05	13786
328	SeriesReport	bbennett	2017-06-01 08:14:07-05	2017-06-01 08:14:08-05	1575
329	ListOfCollectionsAndSitesLikeCollection	bbennett	2017-06-01 08:35:42-05	2017-06-01 08:35:46-05	1
330	ListOfCollectionsAndSitesLikeCollection	bbennett	2017-06-01 08:36:24-05	2017-06-01 08:36:24-05	1
331	ShowFilesHiddenByCollectionSite	bbennett	2017-06-01 08:36:58-05	2017-06-01 08:36:59-05	8
332	ShowFilesHiddenByCollectionSite	bbennett	2017-06-01 08:38:50-05	2017-06-01 08:38:50-05	1
333	SeriesReport	bbennett	2017-06-01 08:56:12-05	2017-06-01 08:56:12-05	1575
334	ListOfCollectionsAndSitesLikeCollection	bbennett	2017-06-01 09:25:23-05	2017-06-01 09:25:25-05	4
335	CountsByCollectionDateRange	bbennett	2017-06-01 09:27:23-05	2017-06-01 09:27:24-05	0
336	CountsByCollectionDateRangePlus	bbennett	2017-06-01 09:27:55-05	2017-06-01 09:27:55-05	0
337	CountsByCollectionDateRangePlus	bbennett	2017-06-01 09:28:52-05	2017-06-01 09:28:52-05	0
338	ListOfCollectionsAndSitesLikeCollection	bbennett	2017-06-01 09:29:32-05	2017-06-01 09:29:33-05	4
339	CountsByCollectionDateRangePlus	bbennett	2017-06-01 09:30:08-05	2017-06-01 09:30:44-05	1
340	CountsByCollectionDateRangePlus	bbennett	2017-06-01 09:32:33-05	2017-06-01 09:32:37-05	1
341	SeriesReport	bbennett	2017-06-01 10:57:11-05	2017-06-01 10:57:11-05	1575
342	LongestRunningNQueries	bbennett	2017-06-01 11:26:37-05	2017-06-01 11:26:37-05	50
343	CurrentPatientStatii	bbennett	2017-06-01 13:28:23-05	2017-06-01 13:31:55-05	2423
344	ListOfQueriesPerformedByDate	bbennett	2017-06-01 13:32:20-05	2017-06-01 13:32:20-05	20
345	RoundInfoLastCompleteRound	bbennett	2017-06-01 13:43:02-05	2017-06-01 13:43:03-05	1
346	ListOfQueriesPerformedByUserByDate	bbennett	2017-06-01 13:43:39-05	2017-06-01 13:43:39-05	22
347	FastCurrentPatientStatii	bbennett	2017-06-01 13:44:16-05	2017-06-01 13:44:16-05	2444
348	CurrentPatientStatii	bbennett	2017-06-01 13:42:02-05	2017-06-01 13:45:28-05	2423
349	CurrentPatientWithoutStatii	bbennett	2017-06-01 13:50:04-05	2017-06-01 13:50:05-05	79
350	FastCurrentPatientStatii	bbennett	2017-06-01 13:53:00-05	2017-06-01 13:53:00-05	2521
351	CountsByCollectionDateRange	tracyn	2017-06-01 17:14:14-05	2017-06-01 17:15:01-05	127
352	CountsByCollectionDateRange	tracyn	2017-06-01 17:48:17-05	2017-06-01 17:49:03-05	129
353	CountsByCollectionDateRange	tracyn	2017-06-01 17:50:24-05	2017-06-01 17:51:11-05	129
354	ListOfCollectionsAndSites	ksmith01	2017-06-01 18:16:05-05	2017-06-01 18:16:29-05	77
355	CountsByCollectionDateRange	ksmith01	2017-06-01 18:18:10-05	2017-06-01 18:18:12-05	1
356	GetBacklogQueueSizeWithCollection	ksmith01	2017-06-01 20:41:49-05	2017-06-01 20:41:49-05	0
357	GetBacklogCountAndPrioritySummary	ksmith01	2017-06-01 20:42:08-05	2017-06-01 20:42:08-05	0
358	CountsByCollectionDateRange	ksmith01	2017-06-01 20:43:09-05	2017-06-01 20:43:10-05	1
359	CountsByCollectionDateRange	ksmith01	2017-06-01 20:46:23-05	2017-06-01 20:46:24-05	1
360	ListOfQueriesPerformedByDate	bbennett	2017-06-02 08:04:50-05	2017-06-02 08:04:50-05	0
361	ListOfQueriesPerformedByDate	bbennett	2017-06-02 08:05:04-05	2017-06-02 08:05:05-05	1
362	RoundInfoLastCompleteRound	bbennett	2017-06-02 08:05:28-05	2017-06-02 08:05:29-05	1
363	RoundSummary1Recent	bbennett	2017-06-02 08:05:43-05	2017-06-02 08:05:43-05	4
364	RoundInfoById	bbennett	2017-06-02 08:06:03-05	2017-06-02 08:06:03-05	1
365	TotalsByDateRange	bbennett	2017-06-02 09:34:59-05	2017-06-02 09:35:00-05	0
366	GetPosdaQueueSize	bbennett	2017-06-02 09:35:39-05	2017-06-02 09:35:39-05	1
367	RoundSummaryWithCollectionDateRange	quasarj	2017-06-02 11:14:54-05	2017-06-02 11:14:55-05	0
368	RoundSummaryWithCollectionDateRange	quasarj	2017-06-02 11:14:58-05	2017-06-02 11:14:59-05	4
369	RoundInfoById	quasarj	2017-06-02 11:15:17-05	2017-06-02 11:15:17-05	1
370	SubjectsWithDupSopsByCollectionSite	tracyn	2017-06-02 11:52:49-05	2017-06-02 11:54:53-05	2
371	SubjectsWithDupSopsByCollectionSite	tracyn	2017-06-02 11:56:07-05	2017-06-02 11:57:07-05	2
372	CountsByCollectionDateRange	tracyn	2017-06-02 12:26:31-05	2017-06-02 12:26:33-05	319
373	CountsByCollectionDateRange	tracyn	2017-06-02 12:29:02-05	2017-06-02 12:29:04-05	319
374	FindInconsistentSeries	tracyn	2017-06-02 12:29:54-05	2017-06-02 12:29:55-05	0
375	FindInconsistentStudy	tracyn	2017-06-02 12:30:06-05	2017-06-02 12:30:07-05	0
376	SubjectsWithDupSopsByCollection	tracyn	2017-06-02 12:30:58-05	2017-06-02 12:31:00-05	0
377	DistinctSeriesByCollectionSite	tracyn	2017-06-02 12:31:55-05	2017-06-02 12:31:57-05	319
378	TotalsByDateRange	bbennett	2017-06-02 12:39:41-05	2017-06-02 12:39:41-05	1
379	TotalsByDateRange	bbennett	2017-06-02 12:41:06-05	2017-06-02 12:41:06-05	1
380	CountsByCollectionDateRange	bbennett	2017-06-02 12:41:41-05	2017-06-02 12:41:45-05	4
381	CountsByCollectionDateRange	bbennett	2017-06-02 12:44:04-05	2017-06-02 12:44:09-05	4
382	DistinctSeriesByCollection	bbennett	2017-06-02 12:44:58-05	2017-06-02 12:44:58-05	4
383	PhiSimpleScanStatus	bbennett	2017-06-02 12:52:49-05	2017-06-02 12:52:49-05	19
384	SimplePhiReportAll	bbennett	2017-06-02 12:54:08-05	2017-06-02 12:54:19-05	1730
385	ListOfCollectionsBySite	bbennett	2017-06-02 13:30:04-05	2017-06-02 13:30:08-05	0
386	ListOfCollectionsAndSitesLikeCollection	bbennett	2017-06-02 13:30:18-05	2017-06-02 13:30:19-05	1
387	SimplePhiScanStatusInProcess	tracyn	2017-06-02 13:30:26-05	2017-06-02 13:30:26-05	0
388	SimplePhiScanStatusInProcess	tracyn	2017-06-02 13:31:13-05	2017-06-02 13:31:13-05	0
389	CountsByCollectionDateRange	bbennett	2017-06-02 13:31:20-05	2017-06-02 13:31:23-05	0
390	PhiSimpleScanStatus	tracyn	2017-06-02 13:31:23-05	2017-06-02 13:31:23-05	19
391	CountsByCollectionDateRange	bbennett	2017-06-02 13:32:06-05	2017-06-02 13:32:08-05	51
392	SimplePhiReportAll	tracyn	2017-06-02 13:32:49-05	2017-06-02 13:33:31-05	62849
393	SimplePhiScanStatusInProcess	bbennett	2017-06-02 13:39:36-05	2017-06-02 13:39:36-05	1
394	SimplePhiScanStatusInProcess	bbennett	2017-06-02 13:39:54-05	2017-06-02 13:39:54-05	1
395	SimplePhiScanStatusInProcess	bbennett	2017-06-02 13:40:02-05	2017-06-02 13:40:02-05	1
396	SimplePhiScanStatusInProcess	bbennett	2017-06-02 13:40:17-05	2017-06-02 13:40:17-05	1
397	SimplePhiScanStatusInProcess	bbennett	2017-06-02 13:40:44-05	2017-06-02 13:40:44-05	1
398	PhiSimpleScanStatus	bbennett	2017-06-02 13:41:03-05	2017-06-02 13:41:03-05	20
399	SimplePhiReportAll	bbennett	2017-06-02 13:43:28-05	2017-06-02 13:43:47-05	18936
400	PhiSimpleScanStatus	bbennett	2017-06-02 13:43:48-05	2017-06-02 13:43:48-05	20
401	SimplePublicPhiReportSelectedVR	bbennett	2017-06-02 13:46:40-05	2017-06-02 13:47:09-05	7422
402	SimplePublicPhiReportSelectedVR	bbennett	2017-06-02 13:50:15-05	2017-06-02 13:50:44-05	7422
403	PhiSimpleScanStatus	tracyn	2017-06-02 13:52:21-05	2017-06-02 13:52:21-05	20
404	GetSeriesWithImageByCollectionSite	tracyn	2017-06-02 13:58:16-05	2017-06-02 14:00:19-05	1800
405	TotalsByDateRange	bbennett	2017-06-02 14:02:32-05	2017-06-02 14:02:32-05	2
406	TotalsByDateRange	quasarj	2017-06-02 14:03:43-05	2017-06-02 14:03:43-05	1
407	GetSeriesWithImageByCollectionSite	tracyn	2017-06-02 14:13:00-05	2017-06-02 14:13:06-05	319
408	CountsByCollectionDateRange	ksmith01	2017-06-02 14:24:24-05	2017-06-02 14:24:27-05	1
409	CountsByCollectionDateRange	ksmith01	2017-06-02 14:25:27-05	2017-06-02 14:25:28-05	1
410	GetBacklogCountAndPrioritySummary	ksmith01	2017-06-02 14:50:35-05	2017-06-02 14:50:36-05	1
411	GetBacklogQueueSizeWithCollection	ksmith01	2017-06-02 14:51:07-05	2017-06-02 14:51:07-05	0
412	GetBacklogCountAndPrioritySummary	ksmith01	2017-06-02 14:51:22-05	2017-06-02 14:51:22-05	0
413	GetBacklogCountAndPrioritySummary	ksmith01	2017-06-02 14:51:36-05	2017-06-02 14:51:36-05	0
414	GetBacklogQueueSize	ksmith01	2017-06-02 14:51:49-05	2017-06-02 14:51:50-05	1
415	GetPosdaQueueSize	ksmith01	2017-06-02 14:52:05-05	2017-06-02 14:52:06-05	1
416	GetListCollectionPrios	ksmith01	2017-06-02 14:52:26-05	2017-06-02 14:52:26-05	52
417	RoundSummary1Recent	ksmith01	2017-06-02 14:53:01-05	2017-06-02 14:53:01-05	8
418	RoundInfoById	ksmith01	2017-06-02 14:53:51-05	2017-06-02 14:53:52-05	1
419	DistinctSeriesByCollectionSite	tracyn	2017-06-02 15:01:05-05	2017-06-02 15:02:45-05	1800
420	RoundSummaryWithCollectionDateRange	tracyn	2017-06-02 15:12:38-05	2017-06-02 15:12:39-05	34516
421	RoundSummaryWithCollectionDateRange	tracyn	2017-06-02 15:18:31-05	2017-06-02 15:18:33-05	164
422	CountsByCollectionDateRange	tracyn	2017-06-02 15:19:44-05	2017-06-02 15:20:03-05	159
423	TotalsByDateRange	tracyn	2017-06-02 15:58:51-05	2017-06-02 15:58:53-05	13
424	CurrentPatientStatii	tracyn	2017-06-02 16:01:50-05	2017-06-02 16:05:45-05	2568
425	PhiSimpleScanStatus	tracyn	2017-06-02 18:54:47-05	2017-06-02 18:54:48-05	21
426	SimplePhiScanStatusInProcess	tracyn	2017-06-02 18:55:19-05	2017-06-02 18:55:19-05	1
427	SimplePhiScanStatusInProcess	tracyn	2017-06-02 19:06:17-05	2017-06-02 19:06:18-05	1
428	SimplePhiScanStatusInProcess	tracyn	2017-06-02 19:06:26-05	2017-06-02 19:06:26-05	1
429	RoundInfoLastCompleteRound	bbennett	2017-06-05 07:52:50-05	2017-06-05 07:52:51-05	1
430	RoundCountsByCollection2	bbennett	2017-06-05 07:53:19-05	2017-06-05 07:53:19-05	10
431	RoundCountsByCollection2Recent	bbennett	2017-06-05 07:56:07-05	2017-06-05 07:56:07-05	0
432	RoundCountsByCollection2DateRange	bbennett	2017-06-05 07:56:35-05	2017-06-05 07:56:36-05	4
433	RoundSummary1DateRange	bbennett	2017-06-05 07:56:51-05	2017-06-05 07:56:51-05	56
434	RoundInfoById	bbennett	2017-06-05 07:57:03-05	2017-06-05 07:57:03-05	1
435	TotalsByDateRange	bbennett	2017-06-05 07:57:27-05	2017-06-05 07:57:28-05	3
436	ListOfQueriesPerformedByDate	bbennett	2017-06-05 08:30:28-05	2017-06-05 08:30:28-05	267
437	QueryArgsByQueryId	bbennett	2017-06-05 08:31:58-05	2017-06-05 08:31:58-05	2
438	QueryByName	bbennett	2017-06-05 08:34:51-05	2017-06-05 08:34:51-05	1
439	ListOfAvailableQueriesByNameLike	bbennett	2017-06-05 08:35:16-05	2017-06-05 08:35:16-05	6
440	ListOfAvailableQueriesByTag	bbennett	2017-06-05 08:35:37-05	2017-06-05 08:35:37-05	0
441	ListOfAvailableQueriesByTag	bbennett	2017-06-05 08:35:53-05	2017-06-05 08:35:53-05	0
442	ListOfAvailableQueriesByTagLike	bbennett	2017-06-05 08:36:08-05	2017-06-05 08:36:08-05	157
443	ListOfAvailableQueries	bbennett	2017-06-05 08:37:03-05	2017-06-05 08:37:03-05	593
444	QueryByName	bbennett	2017-06-05 08:38:47-05	2017-06-05 08:38:47-05	1
445	PatientStudySeriesHierarchyByCollectionSiteExt	bbennett	2017-06-05 08:40:29-05	2017-06-05 08:40:29-05	0
446	PatientStudySeriesHierarchyByCollectionSiteExt	bbennett	2017-06-05 08:40:56-05	2017-06-05 08:41:04-05	0
447	ListOfCollectionsAndSitesLikeCollection	bbennett	2017-06-05 08:41:22-05	2017-06-05 08:41:27-05	1
448	PatientStudySeriesHierarchyByCollectionSiteExt	bbennett	2017-06-05 08:42:05-05	2017-06-05 08:42:20-05	51
449	PhiSimpleScanStatus	bbennett	2017-06-05 08:45:17-05	2017-06-05 08:45:17-05	21
450	SimplePhiReportAllRelevantPrivateOnlyNew	bbennett	2017-06-05 08:45:38-05	2017-06-05 08:45:54-05	2533
451	LongestRunningNQueries	bbennett	2017-06-05 09:23:12-05	2017-06-05 09:23:12-05	50
452	GetPlansReferencingBadSS	bbennett	2017-06-05 09:36:51-05	2017-06-05 09:36:54-05	0
453	PhiScanStatus	tracyn	2017-06-05 10:45:46-05	2017-06-05 10:45:46-05	6
454	PhiSimpleScanStatus	tracyn	2017-06-05 10:46:11-05	2017-06-05 10:46:11-05	21
455	SimplePhiReportAll	tracyn	2017-06-05 10:48:11-05	2017-06-05 10:52:47-05	1480245
456	SimplePhiReportAll	tracyn	2017-06-05 10:55:25-05	2017-06-05 10:59:56-05	1480245
457	CountsByCollectionSiteDateRange	tracyn	2017-06-05 11:59:34-05	2017-06-05 11:59:49-05	159
458	FindInconsistentSeries	bbennett	2017-06-05 13:27:07-05	2017-06-05 13:27:07-05	0
459	FindInconsistentStudy	bbennett	2017-06-05 13:27:17-05	2017-06-05 13:27:17-05	17
460	StudyConsistency	bbennett	2017-06-05 13:27:28-05	2017-06-05 13:27:36-05	2
461	GetSimilarDupContourCounts	quasarj	2017-06-05 13:53:45-05	2017-06-05 13:53:57-05	2
462	CountsByCollectionSiteDateRange	tracyn	2017-06-05 16:13:05-05	2017-06-05 16:13:21-05	159
463	GetSeriesWithImageAndNoEquivalenceClassByCollectionSiteDateRange	bbennett	2017-06-06 12:14:33-05	2017-06-06 12:15:48-05	0
464	DuplicateSopsInSeries	bbennett	2017-06-06 13:33:47-05	2017-06-06 13:33:49-05	0
465	SubjectsWithDupSops	bbennett	2017-06-06 13:34:02-05	2017-06-06 13:35:09-05	52
466	DupSopsByCollectionSiteDateRange	bbennett	2017-06-06 13:36:13-05	2017-06-06 13:36:14-05	1452
467	CountsByCollectionSiteDateRange	bbennett	2017-06-06 13:39:19-05	2017-06-06 13:39:33-05	159
468	FilesAndLoadTimesInSeries	bbennett	2017-06-06 13:40:53-05	2017-06-06 13:40:53-05	1
469	CountsByCollectionDateRange	tracyn	2017-06-06 13:43:30-05	2017-06-06 13:44:17-05	129
470	FindInconsistentSeries	bbennett	2017-06-06 13:46:38-05	2017-06-06 13:46:38-05	3
471	SeriesConsistency	bbennett	2017-06-06 13:46:51-05	2017-06-06 13:46:51-05	2
472	WhereSeriesSits	bbennett	2017-06-06 13:47:33-05	2017-06-06 13:47:44-05	2
473	WhereSeriesSitsQuick	bbennett	2017-06-06 14:13:46-05	2017-06-06 14:13:50-05	1
474	PhiSimpleScanStatus	bbennett	2017-06-06 14:19:13-05	2017-06-06 14:19:14-05	21
475	CountsByCollectionDateRange	tracyn	2017-06-06 14:27:03-05	2017-06-06 14:27:04-05	2
476	DupSopsByCollectionSiteDateRange	tracyn	2017-06-06 14:28:20-05	2017-06-06 14:28:21-05	0
477	DupSopsByCollectionSiteDateRange	bbennett	2017-06-06 14:28:29-05	2017-06-06 14:28:30-05	1452
478	DupSopsByCollectionSiteDateRange	tracyn	2017-06-06 14:28:40-05	2017-06-06 14:28:41-05	0
479	CountsByCollectionDateRange	tracyn	2017-06-06 14:29:15-05	2017-06-06 14:30:01-05	129
480	DupSopsByCollectionDateRange	bbennett	2017-06-06 14:30:43-05	2017-06-06 14:30:43-05	0
481	DupSopsByCollectionDateRange	bbennett	2017-06-06 14:31:29-05	2017-06-06 14:31:53-05	0
482	RoundCountsByCollection2DateRange	bbennett	2017-06-06 14:38:19-05	2017-06-06 14:38:20-05	0
483	ListOfCollectionsAndSites	bbennett	2017-06-06 14:38:38-05	2017-06-06 14:39:01-05	78
484	RoundCountsByCollection2DateRange	bbennett	2017-06-06 14:39:51-05	2017-06-06 14:39:51-05	7
485	ListOfCollectionsBySite	bbennett	2017-06-06 15:13:36-05	2017-06-06 15:13:37-05	1
486	CountsByCollectionDateRangePlus	bbennett	2017-06-06 15:14:30-05	2017-06-06 15:14:31-05	4
487	CountsByCollectionDateRangePlus	bbennett	2017-06-06 15:15:29-05	2017-06-06 15:15:49-05	319
488	GetPlansReferencingBadSS	bbennett	2017-06-06 15:42:43-05	2017-06-06 15:42:46-05	0
489	GetDupContourCounts	bbennett	2017-06-06 15:43:52-05	2017-06-06 15:43:57-05	986
490	GetDupsFromSimilarDupContourCounts	bbennett	2017-06-06 15:44:20-05	2017-06-06 15:44:56-05	132
491	ListOfCollectionsAndSitesLikeCollection	bbennett	2017-06-06 15:47:14-05	2017-06-06 15:47:16-05	4
492	PatientStudySopCountByCollectionSite	bbennett	2017-06-06 15:50:15-05	2017-06-06 15:50:19-05	6
493	CountsByCollectionSiteDateRange	bbennett	2017-06-06 15:51:12-05	2017-06-06 15:51:37-05	6
494	FindInconsistentSeries	bbennett	2017-06-06 15:53:18-05	2017-06-06 15:53:18-05	0
495	FindInconsistentStudy	bbennett	2017-06-06 15:53:31-05	2017-06-06 15:53:31-05	0
496	DistinctSeriesByCollection	bbennett	2017-06-07 07:02:30-05	2017-06-07 07:02:33-05	6
497	DistinctSeriesByCollection	bbennett	2017-06-07 07:04:06-05	2017-06-07 07:04:06-05	6
498	DistinctSeriesByCollection	bbennett	2017-06-07 07:17:27-05	2017-06-07 07:17:27-05	6
499	DistinctSeriesByCollection	bbennett	2017-06-07 07:19:03-05	2017-06-07 07:19:03-05	6
500	DistinctSeriesByCollection	bbennett	2017-06-07 07:29:16-05	2017-06-07 07:29:17-05	6
501	DistinctSeriesByCollection	bbennett	2017-06-07 07:50:18-05	2017-06-07 07:50:18-05	6
502	TagsSeenSimple	bbennett	2017-06-07 08:03:37-05	2017-06-07 08:03:37-05	2159
503	DispositonsNeededSimple	bbennett	2017-06-07 08:09:55-05	2017-06-07 08:10:11-05	4
504	DispositonsNeededSimple	bbennett	2017-06-07 08:13:37-05	2017-06-07 08:13:37-05	0
505	DispositonsSimple	bbennett	2017-06-07 08:13:47-05	2017-06-07 08:13:47-05	1302
506	PrivateTagsWhichArentMarked	bbennett	2017-06-07 08:21:20-05	2017-06-07 08:21:20-05	0
507	CreateSimpleElementSeen	bbennett	2017-06-07 10:17:36-05	2017-06-07 10:17:36-05	1
508	ListOfQueriesPerformedByUserByDate	bbennett	2017-06-07 10:18:47-05	2017-06-07 10:18:47-05	12
509	QueryArgsByQueryId	bbennett	2017-06-07 10:18:57-05	2017-06-07 10:18:57-05	2
510	GetPopupDefinition	bbennett	2017-06-07 11:32:07-05	2017-06-07 11:32:07-05	1
511	GetPopupDefinition	bbennett	2017-06-07 11:36:10-05	2017-06-07 11:36:10-05	1
512	DistinctSeriesByCollection	bbennett	2017-06-07 11:38:19-05	2017-06-07 11:38:22-05	6
513	DistinctSeriesByCollection	bbennett	2017-06-07 11:40:44-05	2017-06-07 11:40:44-05	6
514	DistinctSeriesByCollection	bbennett	2017-06-07 12:22:58-05	2017-06-07 12:22:59-05	6
515	DistinctSeriesByCollection	bbennett	2017-06-07 12:23:47-05	2017-06-07 12:23:47-05	6
516	DistinctSeriesByCollection	bbennett	2017-06-07 12:25:51-05	2017-06-07 12:25:51-05	6
517	DistinctSeriesByCollection	bbennett	2017-06-07 12:29:23-05	2017-06-07 12:29:24-05	6
518	DistinctSeriesByCollection	bbennett	2017-06-07 12:30:31-05	2017-06-07 12:30:31-05	6
519	DistinctSeriesByCollection	bbennett	2017-06-07 12:32:44-05	2017-06-07 12:32:44-05	6
520	DistinctSeriesByCollection	bbennett	2017-06-07 12:34:10-05	2017-06-07 12:34:11-05	6
521	GetPopupDefinition	bbennett	2017-06-07 13:18:13-05	\N	\N
522	GetPopupDefinition	bbennett	2017-06-07 13:19:25-05	\N	\N
523	GetPopupDefinition	bbennett	2017-06-07 13:19:53-05	2017-06-07 13:19:53-05	1
525	ListOfQueriesPerformedByUserByDate	bbennett	2017-06-07 13:28:08-05	2017-06-07 13:28:08-05	26
526	ListOfQueriesPerformedByUserByDate	bbennett	2017-06-07 13:28:55-05	2017-06-07 13:28:55-05	2
524	PixelTypes	bbennett	2017-06-07 13:25:38-05	2017-06-07 13:31:07-05	55
527	FileIdByPixelType	bbennett	2017-06-07 13:31:47-05	\N	\N
528	FileIdByPixelType	bbennett	2017-06-07 13:34:01-05	2017-06-07 13:34:02-05	31
529	FileIdByPixelType	bbennett	2017-06-07 13:36:28-05	\N	\N
530	FileIdByPixelType	bbennett	2017-06-07 13:37:16-05	\N	\N
531	FileIdByPixelType	bbennett	2017-06-07 13:37:34-05	2017-06-07 13:37:34-05	100
532	FileIdByPixelType	bbennett	2017-06-07 13:39:19-05	\N	\N
533	FileIdByPixelType	bbennett	2017-06-07 13:41:53-05	\N	\N
534	FileIdByPixelType	bbennett	2017-06-08 06:59:29-05	\N	\N
535	FileIdByPixelType	bbennett	2017-06-08 07:00:38-05	2017-06-08 07:00:51-05	100
536	FileIdByPixelType	bbennett	2017-06-08 07:07:17-05	2017-06-08 07:07:18-05	100
537	FileIdByPixelType	bbennett	2017-06-08 07:08:02-05	\N	\N
538	FileIdByPixelType	bbennett	2017-06-08 07:09:07-05	2017-06-08 07:09:08-05	100
539	PixelTypes	bbennett	2017-06-08 07:36:46-05	2017-06-08 07:42:11-05	55
540	FileIdByPixelType	bbennett	2017-06-08 07:46:06-05	2017-06-08 07:46:07-05	100
541	FileIdByPixelType	bbennett	2017-06-08 07:46:46-05	\N	\N
542	FileIdByPixelType	bbennett	2017-06-08 07:47:46-05	\N	\N
543	FileIdByPixelType	bbennett	2017-06-08 07:47:57-05	2017-06-08 07:47:58-05	100
544	PhiSimpleScanStatus	bbennett	2017-06-08 08:19:23-05	2017-06-08 08:19:23-05	21
545	DistinctSeriesByCollection	bbennett	2017-06-08 08:19:51-05	2017-06-08 08:22:03-05	1511
546	SimplePhiScanStatusInProcess	bbennett	2017-06-08 08:28:31-05	2017-06-08 08:28:31-05	0
547	SimplePhiScanStatusInProcess	bbennett	2017-06-08 08:28:47-05	2017-06-08 08:28:47-05	1
548	LongestRunningNQueries	bbennett	2017-06-08 08:37:04-05	2017-06-08 08:37:04-05	50
549	LongestRunningNQueriesByDate	bbennett	2017-06-08 08:40:45-05	\N	\N
550	LongestRunningNQueriesByDate	bbennett	2017-06-08 08:41:24-05	2017-06-08 08:41:24-05	11
551	FindTagsInQueries	bbennett	2017-06-08 08:45:23-05	2017-06-08 08:45:23-05	121
552	ListOfAvailableQueriesByTag	bbennett	2017-06-08 08:46:16-05	2017-06-08 08:46:16-05	5
553	SimplePhiScanStatusInProcess	bbennett	2017-06-08 08:47:50-05	2017-06-08 08:47:50-05	1
554	FindInconsistentStudy	tracyn	2017-06-08 09:38:19-05	2017-06-08 09:38:20-05	1
555	StudyConsistency	tracyn	2017-06-08 09:39:04-05	2017-06-08 09:39:16-05	3
556	LongestRunningNQueriesByDate	bbennett	2017-06-08 10:21:44-05	2017-06-08 10:21:44-05	17
557	SimplePhiScanStatusInProcess	bbennett	2017-06-08 10:22:29-05	2017-06-08 10:22:29-05	1
558	SimplePhiScanStatusInProcess	bbennett	2017-06-08 10:22:54-05	2017-06-08 10:22:54-05	1
559	StudyConsistency	bbennett	2017-06-08 10:27:05-05	2017-06-08 10:27:14-05	3
560	StudyHierarchyByStudyUID	bbennett	2017-06-08 10:29:38-05	2017-06-08 10:29:40-05	7
561	WhereSeriesSits	bbennett	2017-06-08 10:32:05-05	2017-06-08 10:32:18-05	2
562	SeriesWithDupSopsByCollectionSite	bbennett	2017-06-08 10:33:07-05	2017-06-08 10:33:08-05	32
563	DuplicateSopsInSeries	bbennett	2017-06-08 10:33:55-05	2017-06-08 10:34:37-05	4
564	DuplicateFilesBySop	bbennett	2017-06-08 10:35:21-05	2017-06-08 10:35:21-05	2
565	FilesVisibilityByCollectionSitePatient	bbennett	2017-06-08 12:42:02-05	\N	\N
566	FilesVisibilityByCollectionSitePatient	bbennett	2017-06-08 12:43:03-05	\N	\N
567	FilesVisibilityByCollectionSitePatient	bbennett	2017-06-08 12:43:48-05	2017-06-08 12:43:48-05	620
568	FilesVisibilityByCollectionSitePatient	bbennett	2017-06-08 12:45:08-05	2017-06-08 12:45:08-05	357
569	FilesByCollectionSitePatientVisibility	bbennett	2017-06-08 12:47:26-05	2017-06-08 12:47:26-05	0
570	FilesByCollectionSitePatientVisibility	bbennett	2017-06-08 12:48:02-05	2017-06-08 12:48:02-05	263
571	VisibleFilesByCollectionSitePatient	bbennett	2017-06-08 12:49:01-05	\N	\N
572	VisibleFilesByCollectionSitePatient	bbennett	2017-06-08 12:49:20-05	2017-06-08 12:49:20-05	357
573	VisibleFilesByCollectionSitePatient	bbennett	2017-06-08 12:51:08-05	2017-06-08 12:51:08-05	357
574	TotalsByDateRange	ksmith01	2017-06-08 19:34:12-05	2017-06-08 19:34:14-05	13
575	TotalsByDateRange	ksmith01	2017-06-08 19:36:34-05	2017-06-08 19:53:00-05	77
576	FilesInSeries	bbennett	2017-06-09 09:27:59-05	2017-06-09 09:28:00-05	311
577	FilesInSeries	bbennett	2017-06-09 09:29:35-05	2017-06-09 09:29:35-05	311
578	DistinctSeriesByCollectionSiteSubject	bbennett	2017-06-09 09:32:10-05	2017-06-09 09:32:11-05	11
579	FilesAndLoadTimesInSeries	bbennett	2017-06-09 09:33:14-05	2017-06-09 09:33:15-05	933
580	FilesAndLoadTimesInSeries	bbennett	2017-06-09 09:34:06-05	2017-06-09 09:34:06-05	311
581	TotalsByDateRange	tracyn	2017-06-09 10:53:32-05	\N	\N
582	TotalsByDateRange	tracyn	2017-06-09 10:53:44-05	2017-06-09 10:53:45-05	4
583	CtWithBadModality	bbennett	2017-06-09 12:48:23-05	\N	\N
584	CtWithBadModality	bbennett	2017-06-09 12:48:46-05	\N	\N
585	CtWithBadModality	bbennett	2017-06-09 12:49:13-05	2017-06-09 12:49:38-05	29
586	MRWithBadModality	bbennett	2017-06-09 13:10:09-05	2017-06-09 13:10:16-05	16
587	PTWithBadModality	bbennett	2017-06-09 13:12:09-05	2017-06-09 13:12:12-05	0
588	RTSTRUCTWithBadModality	bbennett	2017-06-09 13:13:15-05	2017-06-09 13:13:16-05	0
589	RTPLANWithBadModality	bbennett	2017-06-09 13:14:04-05	2017-06-09 13:14:06-05	295
590	RTPLANWithBadModality	bbennett	2017-06-09 13:14:33-05	2017-06-09 13:14:33-05	0
591	RTDOSEWithBadModality	bbennett	2017-06-09 13:16:07-05	2017-06-09 13:16:08-05	0
592	FindTagsInQueries	bbennett	2017-06-09 13:36:51-05	2017-06-09 13:36:51-05	121
593	FindTagsInQuery	bbennett	2017-06-09 13:37:05-05	2017-06-09 13:37:05-05	1
594	CtWithBadModality	bbennett	2017-06-09 13:53:11-05	2017-06-09 13:53:18-05	29
595	GetBacklogCountAndPrioritySummary	ksmith01	2017-06-09 14:14:36-05	2017-06-09 14:14:37-05	0
596	RoundCountsByCollection2Recent	ksmith01	2017-06-09 14:17:35-05	2017-06-09 14:17:35-05	0
597	RoundCountsByCollection2Recent	ksmith01	2017-06-09 14:18:11-05	2017-06-09 14:18:11-05	1
598	ShowAllHideEventsByCollectionSite	bbennett	2017-06-09 15:20:01-05	2017-06-09 15:20:12-05	72988
599	VisibilityChangeEventsByCollectionForHiddenFiles	bbennett	2017-06-09 15:21:46-05	2017-06-09 15:21:50-05	177
600	ShowAllHideEventsByCollectionSiteAlt	bbennett	2017-06-09 15:24:15-05	2017-06-09 15:24:17-05	3
601	VisibilityChangeEventsByCollectionForAllFiles	bbennett	2017-06-09 15:32:46-05	2017-06-09 15:33:03-05	177
602	VisibilityChangeEventsByCollectionForAllFiles	bbennett	2017-06-09 15:33:55-05	2017-06-09 15:34:02-05	89
603	VisibilityChangeEventsByCollectionForAllFiles	bbennett	2017-06-09 15:36:02-05	2017-06-09 15:36:05-05	3
604	VisibilityChangeEventsByCollectionForAllFiles	bbennett	2017-06-09 15:36:36-05	2017-06-09 15:36:38-05	3
605	GetBacklogCountAndPrioritySummary	ksmith01	2017-06-09 21:14:41-05	2017-06-09 21:14:41-05	0
606	RoundCountsByCollection2Recent	ksmith01	2017-06-09 21:15:03-05	2017-06-09 21:15:03-05	0
607	GetBacklogQueueSize	ksmith01	2017-06-09 21:15:19-05	2017-06-09 21:15:20-05	1
608	GetPosdaQueueSize	ksmith01	2017-06-09 21:16:14-05	2017-06-09 21:16:15-05	1
609	RoundSummary1Recent	ksmith01	2017-06-09 21:16:33-05	2017-06-09 21:16:33-05	10
610	GetListCollectionPrios	ksmith01	2017-06-09 21:17:26-05	2017-06-09 21:17:26-05	53
611	RoundCountsByCollection2Recent	ksmith01	2017-06-09 21:19:26-05	2017-06-09 21:19:26-05	0
612	CountsByCollectionSiteDateRange	tracyn	2017-06-09 21:21:38-05	2017-06-09 21:21:44-05	89
613	CountsByCollectionSiteDateRange	ksmith01	2017-06-09 21:23:09-05	2017-06-09 21:23:49-05	41
614	CountsByCollectionSiteDateRange	tracyn	2017-06-09 21:23:54-05	2017-06-09 21:23:54-05	2
615	CountsByCollectionSiteDateRange	tracyn	2017-06-09 21:35:47-05	2017-06-09 21:35:47-05	0
616	TotalsByDateRange	tracyn	2017-06-09 21:49:40-05	\N	\N
617	MakeBacklogReadyForProcessing	bbennett	2017-06-12 07:31:02-05	2017-06-12 07:31:02-05	1
618	DupSopsByCollectionDateRange	bbennett	2017-06-12 07:48:51-05	2017-06-12 07:48:51-05	0
620	ListOfQueriesPerformedByDate	bbennett	2017-06-12 07:49:56-05	2017-06-12 07:49:57-05	2
619	SubjectsWithDupSops	bbennett	2017-06-12 07:49:05-05	2017-06-12 07:50:14-05	54
621	SeriesWithDupSopsByCollectionSiteDateRange	bbennett	2017-06-12 07:52:29-05	2017-06-12 07:52:31-05	4
622	FilesAndLoadTimesInSeries	bbennett	2017-06-12 07:52:44-05	2017-06-12 07:52:44-05	168
623	CurrentPatientStatiiByCollectionSite	tracyn	2017-06-12 10:01:33-05	2017-06-12 10:01:35-05	19
624	CurrentPatientStatiiByCollectionSite	tracyn	2017-06-12 10:07:32-05	2017-06-12 10:07:32-05	19
625	TotalsByDateRange	tracyn	2017-06-12 10:07:55-05	2017-06-12 10:24:58-05	78
626	CountsByCollectionSiteDateRange	tracyn	2017-06-12 10:30:02-05	2017-06-12 10:30:39-05	454
627	RoundInfoLastCompleteRound	bbennett	2017-06-13 08:27:29-05	2017-06-13 08:27:30-05	1
628	CountsByCollectionSiteDateRange	tracyn	2017-06-13 09:06:13-05	2017-06-13 09:06:33-05	175
629	CountsByCollectionSiteDateRange	tracyn	2017-06-13 12:00:36-05	2017-06-13 12:01:52-05	125
630	GetSeriesWithImageByCollectionSiteDateRange	tracyn	2017-06-13 12:31:12-05	2017-06-13 12:31:20-05	25
631	FindInconsistentStudy	tracyn	2017-06-13 12:35:37-05	2017-06-13 12:35:38-05	2
632	StudyConsistency	tracyn	2017-06-13 12:35:50-05	2017-06-13 12:35:58-05	4
633	FindInconsistentStudy	tracyn	2017-06-13 12:36:38-05	2017-06-13 12:36:39-05	2
634	StudyConsistency	tracyn	2017-06-13 12:36:52-05	2017-06-13 12:36:52-05	2
635	FindInconsistentSeries	tracyn	2017-06-13 12:38:02-05	2017-06-13 12:38:03-05	0
636	DistinctSeriesByCollectionSite	tracyn	2017-06-13 12:39:47-05	2017-06-13 12:39:48-05	122
637	CountsByCollectionSiteDateRange	tracyn	2017-06-13 12:44:39-05	2017-06-13 12:45:25-05	51
638	PhiSimpleScanStatus	tracyn	2017-06-13 12:59:10-05	2017-06-13 12:59:10-05	23
639	SimplePhiReportAllRelevantPrivateOnlyNew	tracyn	2017-06-13 12:59:41-05	2017-06-13 13:00:15-05	624
640	SimplePublicPhiReportSelectedVR	tracyn	2017-06-13 13:00:49-05	2017-06-13 13:01:17-05	11170
641	PhiSimpleScanStatus	bbennett	2017-06-13 14:08:58-05	2017-06-13 14:08:58-05	23
642	VisibilityChangeEventsByCollectionForHiddenFiles	bbennett	2017-06-13 14:11:53-05	2017-06-13 14:12:12-05	186
643	PhiSimpleScanStatus	bbennett	2017-06-13 14:29:16-05	2017-06-13 14:29:17-05	23
644	PhiSimpleScanStatus	bbennett	2017-06-13 14:29:44-05	2017-06-13 14:29:44-05	23
645	ListOfCollectionsAndSitesLikeCollection	bbennett	2017-06-13 14:43:18-05	2017-06-13 14:43:49-05	1
646	CountsByCollectionDateRange	bbennett	2017-06-13 14:44:23-05	2017-06-13 14:44:26-05	0
647	CountsByCollectionDateRange	bbennett	2017-06-13 14:45:21-05	2017-06-13 14:49:08-05	1800
648	ListOfQueriesPerformedByUserByDate	bbennett	2017-06-13 14:51:45-05	2017-06-13 14:51:45-05	8
649	MarkPrivateTags	bbennett	2017-06-13 14:52:59-05	2017-06-13 14:53:00-05	1
650	DispositonsNeededSimple	bbennett	2017-06-13 14:53:11-05	2017-06-13 14:53:29-05	678
651	TagsSeenPrivateWithCountNullDisp	bbennett	2017-06-13 15:49:28-05	2017-06-13 15:49:43-05	231
652	DistinctDispositonsNeededSimple	bbennett	2017-06-13 15:51:11-05	2017-06-13 15:51:25-05	7
653	DistinctDispositonsNeededSimple	bbennett	2017-06-13 15:56:28-05	2017-06-13 15:56:32-05	7
654	DistinctDispositonsNeededSimple	bbennett	2017-06-13 16:04:24-05	2017-06-13 16:04:27-05	7
655	DispositonsNeededSimple	bbennett	2017-06-13 16:06:17-05	2017-06-13 16:06:21-05	678
656	DistinctDispositonsNeededSimple	bbennett	2017-06-13 16:07:11-05	2017-06-13 16:07:15-05	7
657	DistinctDispositonsNeededSimple	bbennett	2017-06-13 16:10:11-05	2017-06-13 16:10:11-05	0
658	VisibilityChangeEventsByCollectionForHiddenFiles	bbennett	2017-06-13 16:11:17-05	2017-06-13 16:11:28-05	186
659	CountsByCollectionDateRange	tracyn	2017-06-13 16:15:28-05	2017-06-13 16:15:28-05	0
660	VisibilityChangeEventsByCollectionDateRangeForHiddenFilesWithSeries	bbennett	2017-06-13 16:15:46-05	2017-06-13 16:15:47-05	861
661	TotalsByDateRange	tracyn	2017-06-13 16:16:22-05	2017-06-13 16:16:22-05	0
662	TotalsByDateRange	tracyn	2017-06-13 16:16:51-05	2017-06-13 16:16:51-05	0
663	VisibilityChangeEventsByCollectionDateRangeForHiddenFilesWithSeries	bbennett	2017-06-13 16:16:56-05	\N	\N
664	VisibilityChangeEventsByCollectionDateRangeForHiddenFilesWithSeries	bbennett	2017-06-13 16:17:29-05	2017-06-13 16:17:29-05	12
665	VisibilityChangeEventsByCollectionDateRangeForHiddenFilesWithSeries	bbennett	2017-06-13 16:18:13-05	2017-06-13 16:18:13-05	12
666	CurrentPatientStatii	tracyn	2017-06-13 16:19:24-05	2017-06-13 16:22:44-05	2608
667	PhiSimpleScanStatus	tracyn	2017-06-13 16:23:31-05	2017-06-13 16:23:31-05	23
668	SimplePhiReportAllRelevantPrivateOnlyNew	tracyn	2017-06-13 16:24:22-05	2017-06-13 16:24:27-05	27
669	SimplePublicPhiReportSelectedVR	tracyn	2017-06-13 16:25:36-05	2017-06-13 16:27:55-05	1194452
\.


--
-- Name: query_invoked_by_dbif_query_invoked_by_dbif_id_seq; Type: SEQUENCE SET; Schema: public; Owner: posda
--

SELECT pg_catalog.setval('query_invoked_by_dbif_query_invoked_by_dbif_id_seq', 669, true);


--
-- Data for Name: query_tabs; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY query_tabs (query_tab_name, query_tab_description, defines_dropdown, sort_order, defines_search_engine) FROM stdin;
legacy	compatable with old interface	t	99	f
count_check	for checking counts	t	10	f
curation	queries used in curation	t	20	f
scripting	queries used in scripts	t	50	f
db_admin	queries used for db_maintenance	t	30	f
\.


--
-- Data for Name: query_tabs_query_tag_filter; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY query_tabs_query_tag_filter (query_tab_name, filter_name, sort_order) FROM stdin;
legacy	counts_patient_status	3
legacy	dicom_batch_file_editing	4
legacy	downloads_by_date	5
legacy	duplicate_sop_evaluation	6
legacy	duplicate_sop_resolution	7
legacy	linkage_check	8
legacy	manage_posda_backlog	9
legacy	monthly_report_queries	10
legacy	phi_review	11
legacy	review_roles	12
legacy	send_data_via_dicom	13
legacy	view_posda_backlog	14
legacy	visual_review_scheduling	15
legacy	visual_review_tracking_processing	16
count_check	view_posda_backlog	1
count_check	downloads_by_date	2
count_check	counts_patient_status	3
curation	duplicate_sop_evaluation	1
curation	duplicate_sop_resolution	2
curation	linkage_check	3
curation	consistency_check	4
legacy	consistency_check	2
legacy	.Unlimited	1
legacy	.Show No Tags	0
scripting	used_in	1
curation	phi_review	5
curation	dicom_batch_file_editing	6
curation	send_data_via_dicom	6
db_admin	db_stats	10
curation	visual_review_scheduling	7
scripting	for_popups	2
db_admin	db_config	20
\.


--
-- Data for Name: query_tag_filter; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY query_tag_filter (filter_name, tags_enabled) FROM stdin;
.Show No Tags	{}
.Unlimited	{}
for_popups	{universal,used_in_process_popup}
view_posda_backlog	{backlog_analysis_reporting_tools,backlog_round_history,backlog_status,universal}
review_roles	{universal,roles}
visual_review_tracking_processing	{visual_review_results,universal}
duplicate_sop_resolution	{universal,dup_sops,hide_dup_sops,distinguished_digest}
send_data_via_dicom	{universal,search_series,send_series,send_directory}
linkage_check	{universal,plan_linkages,dose_linkages,struct_linkages}
manage_posda_backlog	{universal,backlog_status,backlog}
downloads_by_date	{universal}
db_config	{query_tags,query_tabs,popups}
visual_review_scheduling	{universal,visual_review}
duplicate_sop_evaluation	{universal,dup_sops,sops_different_series,series_report}
counts_patient_status	{universal,count_queries,patient_status}
consistency_check	{series_consistency,study_consistency,universal}
dicom_batch_file_editing	{hash_unhashed,hide_files,apply_disposition,universal,edit_files,show_hidden}
monthly_report_queries	{universal,end_of_month}
used_in	{universal,used_in_simple_phi,used_in_file_import_into_posda,used_in_import_edited_files,used_in_reconcile_tag_names,used_processing_structure_set_linkages,used_in_phi_maint,used_in_check_circular_view}
db_stats	{q_stats,q_stats_by_date,q_list,queries,query_tags,universal,schema}
phi_review	{universal,phi_schedule,simple_phi,phi_maint}
\.


--
-- Data for Name: report_inserted; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY report_inserted (report_inserted_id, report_file_in_posda, report_rows_generated) FROM stdin;
\.


--
-- Name: report_inserted_report_inserted_id_seq; Type: SEQUENCE SET; Schema: public; Owner: posda
--

SELECT pg_catalog.setval('report_inserted_report_inserted_id_seq', 1, false);


--
-- Data for Name: spreadsheet_operation; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY spreadsheet_operation (operation_name, command_line, operation_type, input_line_format, tags) FROM stdin;
CompareDuplicateSops	CompareDupSopList.pl	legacy	<sop_instance_uid>	{dup_sops}
ScanPhi	PhiScan.pl <type> "<description>"	legacy	<series_instance_uid>, <signature>	{phi_review}
LinkDirectory	MakeLinkedDirectory.pl <target_dir>	legacy	<path>, <sop_instance_uid>	{send_series}
AddInitialStatus	PopulatePatStat.pl	legacy	<patient_id>, <status>	{patient_status}
ChangePatientStatus	UpdatePatStat.pl <who> "<why>"	legacy	<patient_id>, <old_status>, <new_status>	{patient_status}
SendSeriesToDestination	SendSetOfSeriesToDestination.pl <host> <port> <called> <calling> <user> "<reason>"	legacy	<series_instance_uid>	{send_series}
SeriesConsistency	CheckSeriesConsistency.pl <series_instance_uid>	legacy	\N	\N
StudyConsistency	CheckStudyConsistency.pl <study_instance_uid>	legacy	\N	\N
PatConsistency	CheckPatConsistency.pl "<collection>" <patient_id>	legacy	\N	\N
OnlyIn	OnlyIn.pl Posda Intake	legacy	<SeriesInPosda>, <SeriesInIntake>	\N
TestCommand	TestCommand.pl <host> <port> <called> <calling> <series_instance_uid>	legacy	\N	\N
PipeCommand1	PipeCommand1.pl <var1> <var2> 1 2 3	legacy	<vals1>,<vals2>,<vals3>	\N
SymLinkToIntake	SymLinkToIntake.pl /cache/bbennett/Symlinks	legacy	<PID>, <Modality>, <SopInstance>, <FilePath>	\N
UpdateKnowlegeBase	UpdateKnowledgeBase.pl <who> "<why>"	legacy	<Tag>^<VR>^<Disposition>^<NameChain>	\N
LinkFileHierarchy	LinkFileHierarchy.pl <Destination>	legacy	<patient_id>  <study_instance_uid> <series_instance_uid>	\N
CreatePublicDispositionTable	CreatePublicDispositionTable.pl <sop_class_uid> "<Description>" <who>	legacy	<Tag>^<VR>^<Disposition>^<NameChain>	\N
UpdateCollectionPrio	UpdateBacklogPriorities.pl	legacy	<collection>&<priority>	{backlog_status}
ApplyPublicPrivateDisposition	CsvApplyPublicAndPrivateDisposition.pl <dest_dir> <uid_root> <offset> <low_date> <high_date> <sop_class_uid> "<name>"	legacy	<patient_id>&<study_instance_uid>&<series_instance_uid>	\N
ApplyPrivateDispositionIntake	CsvApplyPrivateDispositionIntake.pl <dest_dir> <uid_root> <offset> <low_date> <high_date>	legacy	<patient_id>&<study_instance_uid>&<series_instance_uid>	\N
ExtractZ	ExtractZ.pl	legacy	<file_id>&<unique_pixel_data_id>&<ipp>	\N
AddPublicHierarchy	AddHierarchyToSpreadsheetByPublicSop.pl <new_root>	legacy	<file>&<Element>&<OldValue>&<NewValue>	\N
ApplyHnsccEdits	ApplyHnsccEdits.pl	legacy	<new_file>&<element>&<new_value>	\N
CompareIntakeFilesToPublicFiles	CompareIntakeFilesToPublicFiles.pl <report_file> <notify>	legacy	<sop_instance_uid> <file_in_intake> <file_in_public>	{compare_collection_site}
CompareDuplicateSopFirstInSeries	CompareDupSopSeriesList.pl	legacy	<series_instance_uid>	{dup_sops}
BackgroundCompareDupSops	BackgroundCompareDupSopList.pl <file_name> "<notify>"	legacy	<sop_instance_uid>&<file_id>&<path>&<first_loaded>	{dup_sops}
BackgroundCompareDuplicateSopFirstInSeries	BackgroundCompareDupSopSeriesList.pl <file_name> "<notify>"	legacy	<series_instance_uid>	{dup_sops}
TdrAndPhiReports	PrepareTdrAndPhiReport.pl	legacy	<id>&<TdrReportFile>&<PhiReportFile>&<notify>	{phi_review}
MakeSelectedTagValueReport	 MakeSelectedTagValueReport.pl /cache/posda/UserData/DbIf/PreparedReports/<report_file_name> <notify>	legacy	<element_signature>&<vr>&<disposition>&<name_chain>&<num_phi_values>&<num_simple_phi_values>	{phi_maint}
EquivalenceClasses	BatchCreateSeriesEquivalenceClasses.pl <notify>	legacy	<series_instance_uid>	{visual_review}
BackgroundCompareSopsInMultipleSeries	BackgroundCompareSopsInMultipleSeries.pl <file_name> "<notify>"	legacy	<series_instance_uid>&<sop_instance_uid>&<file_id>&<file_path>	{sops_different_series}
BulkHashStructUids	BulkHashStructUids.pl <dir> <uid_root> <notify>	legacy	<sop_instance_uid>	{hash_unhashed}
BulkHashDoseLinks	BulkHashDoseLinks.pl <dir> <uid_root> <notify>	legacy	<sop_instance_uid>	{hash_unhashed}
ApplyPrivateDisposition	CsvApplyPrivateDisposition.pl <dest_dir> <uid_root> <offset> <low_date> <high_date>	legacy	<patient_id>&<study_instance_uid>&<series_instance_uid>	{send_series}
ScanDirPhi	PhiDirScan.pl <dir> "<description>"	legacy		{phi_review}
UpdatePrivateDispositions	UpdatePrivateDisposition.pl <who> "<why>"	legacy	<element_signature>&<vr>&<disposition>	{phi_maint}
BatchEditBySop	BatchEditDicomFile.pl /cache/posda/UserData/DbIf/PreparedReports/<report_file> /mnt/public-nfs/posda/edited/<rel_dest_root> <who> "<edit_description>" <notify>	legacy	<command>&<arg1>&<arg2>&<arg3>&<arg4>	{edit_files}
SimplePhiScan	PhiSimpleScan.pl "<description>" <file_query_name> <notify>	legacy	<series_instance_uid>	{simple_phi}
FindSeriesInScanWithPhi	FindSeriesInScanWithPhi.pl <scan_id> "/cache/posda/UserData/DbIf/PreparedReports/<report_name>" <notify>	legacy	<element>&<vr>&<value>&<description>	{simple_phi}
BackgroundCompareFromTo	BackgroundCompareFromToFiles.pl /cache/posda/UserData/DbIf/PreparedReports/<compare_report> <notify>	legacy	<sop_instance_uid>&<from_file>&<to_file>	{dup_sops,edit_files}
ImportEditedFiles	ImportEditedFiles.pl "<report_file_path>" "/cache/posda/UserData/DbIf/PreparedReports/<import_report>" "<edit_comment>" <notify>	legacy	<sop_instance_uid>&<from_digest>&<to_file>&<to_digest>&<status>	{edit_files}
UpdateSimplePrivateDisposition	UpdateSimplePrivateDisposition.pl <who> "<why>"	legacy	<id>&<disp>	{phi_maint}
MakeEditProposal	MakeEditProposal.pl <scan_id> "/cache/posda/UserData/DbIf/PreparedReports/<report_name>" <notify>	legacy	<element>&<vr>&<value>&<description>	{simple_phi}
HideSeriesWithStatus	HideBatchSeriesWithStatus.pl <who> "<why>"	legacy	<series_instance_uid>	{hide_files,hide_dup_sops}
HideEarlyDupSopsInSeries	HideBatchEarlySopDupsInSeries.pl <who> "<why>"	legacy	<series_instance_uid>	{hide_files,hide_dup_sops}
HideFilesWithStatus	HideFilesWithStatus.pl <who> "<why>"	legacy	<file_id>&<old_visibility>	{hide_files,hide_dup_sops}
UnHideFilesWithStatus	UnHideFilesWithStatus.pl <who> "<why>"	legacy	<file_id>&<old_visibility>	{hide_files,hide_dup_sops}
\.


--
-- Data for Name: spreadsheet_uploaded; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY spreadsheet_uploaded (spreadsheet_uploaded_id, time_uploaded, is_executable, uploading_user, file_id_in_posda, number_rows) FROM stdin;
\.


--
-- Name: spreadsheet_uploaded_spreadsheet_uploaded_id_seq; Type: SEQUENCE SET; Schema: public; Owner: posda
--

SELECT pg_catalog.setval('spreadsheet_uploaded_spreadsheet_uploaded_id_seq', 1, false);


--
-- Data for Name: subprocess_invocation; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY subprocess_invocation (subprocess_invocation_id, from_spreadsheet, from_button, spreadsheet_uploaded_id, button_name, command_line, process_pid, invoking_user, when_invoked) FROM stdin;
\.


--
-- Name: subprocess_invocation_subprocess_invocation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: posda
--

SELECT pg_catalog.setval('subprocess_invocation_subprocess_invocation_id_seq', 1, false);


--
-- Data for Name: subprocess_lines; Type: TABLE DATA; Schema: public; Owner: posda
--

COPY subprocess_lines (subprocess_launched_id, line_number, line) FROM stdin;
\.


--
-- PostgreSQL database dump complete
--

