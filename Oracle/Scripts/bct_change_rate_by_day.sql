with level0 as ( select file#,creation_change#,incremental_level,incremental_change#,checkpoint_change#,checkpoint_time,datafile_blocks,blocks,block_size,blocks_read from v$backup_datafile where incremental_level = 0 )
   , level1 as ( select file#,creation_change#,incremental_level,incremental_change#,checkpoint_change#,checkpoint_time,datafile_blocks,blocks,block_size,blocks_read from v$backup_datafile where incremental_level = 1 )
   , level1_detail as ( select level0.file#                  level0_file#
                             , level0.creation_change#       level0_creation_change#
                             , level0.checkpoint_change#     level0_checkpoint_change#
                             , level1.checkpoint_change#     level1_checkpoint_change#
                             , level0.datafile_blocks        level0_datafile_blocks
                             , level1.datafile_blocks        level1_datafile_blocks
                             , trunc(level1.checkpoint_time + to_dsinterval('P0DT0H0M0S') ) level1_time
                             , level1.blocks                 level1_blocks
                             , level0.block_size             level1_block_size
                          from level0
                             , level1
                         where level0.file# = level1.file#
                           and level0.creation_change# = level1.creation_change#
                           and level0.checkpoint_change# = ( select max(checkpoint_change#) 
                                                               from level0 l0i
                                                              where l0i.file# = level1.file#
                                                                and l0i.creation_change# = level1.creation_change#
                                                             having max(l0i.checkpoint_change#) <= level1.incremental_change#
                                                           )
                        )
   , daily_level1_change as ( select level1_time
                                   , sum(level0_datafile_blocks) sum_level0_datafile_blocks
                                   , sum(level1_blocks) sum_level1_blocks
                                from level1_detail
                               group by level1_time
                            )
select level1_time
     , sum_level0_datafile_blocks
     , sum_level1_blocks
     , round( ( sum_level1_blocks / sum_level0_datafile_blocks ) * 100 , 2 ) PCT
  from daily_level1_change
 order by level1_time
/
