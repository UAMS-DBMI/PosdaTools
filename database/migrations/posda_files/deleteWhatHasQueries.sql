/*
	Issue: PT-1024
  Remove obsolete queries that cause confusion for users
*/

delete from queries where name = 'WhatHasComeInRecently';
delete from queries where name = 'WhatHasComeInRecentlyByCollectionLike';
delete from queries where name = 'WhatHasComeInRecentlyByCollectionLikeAndFileInPosdaCount';
delete from queries where name = 'WhatHasComeInRecentlyWithSubject';
delete from queries where name = 'WhatHasComeInRecentlyWithSubjectByCollectionLike';
delete from queries where name = 'WhatHasComeInRecentlyWithSubjectByCollectionLikeAndFileInPosdaCount';
