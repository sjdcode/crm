package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationService {

    int deleteClueActivityRelationByClueIdAndActivityId(String clueId,String activityId);

    int saveCreateClueActivityByList(List<ClueActivityRelation> clueActivityRelations);

}
