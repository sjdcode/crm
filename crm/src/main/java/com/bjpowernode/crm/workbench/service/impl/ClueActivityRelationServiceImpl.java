package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.workbench.domain.ClueActivityRelation;
import com.bjpowernode.crm.workbench.mapper.ClueActivityRelationMapper;
import com.bjpowernode.crm.workbench.service.ClueActivityRelationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service("clueActivityRelationService")
public class ClueActivityRelationServiceImpl implements ClueActivityRelationService {
    @Autowired
    private ClueActivityRelationMapper clueActivityRelationMapper;


    @Override
    public int deleteClueActivityRelationByClueIdAndActivityId(String clueId, String activityId) {
        return clueActivityRelationMapper.deleteClueActivityRelationByClueIdAndActivityId(clueId,activityId);
    }

    @Override
    public int saveCreateClueActivityByList(List<ClueActivityRelation> clueActivityRelations) {
        return clueActivityRelationMapper.insertClueActivityRelationByList(clueActivityRelations);
    }


}
