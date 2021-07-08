/*
	Issue: PT-1024
  Remove obsolete queries that cause confusion for users
*/

delete from queries where name like 'WhatHas%'
