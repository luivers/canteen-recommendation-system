<template>
  <div class="advanced-analysis-container">
    <div class="page-header">
      <h1 class="page-title">高级数据分析</h1>
      <p class="page-desc">深入洞察数据，发现潜在价值</p>
    </div>

    <el-card class="analysis-card">
      <el-tabs v-model="activeTab" class="analysis-tabs">
        <el-tab-pane label="关联规则挖掘" name="association">
          <AssociationRules v-if="activeTab === 'association'" />
        </el-tab-pane>
        <el-tab-pane label="用户分群(RFM)" name="segmentation">
          <UserSegmentation v-if="activeTab === 'segmentation'" />
        </el-tab-pane>
        <el-tab-pane label="异常检测" name="anomaly">
          <AnomalyDetection v-if="activeTab === 'anomaly'" />
        </el-tab-pane>
        <el-tab-pane label="对比分析" name="comparison">
          <ComparisonAnalysis v-if="activeTab === 'comparison'" />
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup>
import { defineAsyncComponent, defineComponent, h, ref } from "vue";
import { ElSkeleton } from "element-plus";

const AnalysisLoading = defineComponent({
  name: "AnalysisLoading",
  setup() {
    return () =>
      h("div", { class: "analysis-loading" }, [
        h(ElSkeleton, { rows: 8, animated: true }),
      ]);
  },
});

const createAsyncAnalysisPanel = (loader) =>
  defineAsyncComponent({
    loader,
    loadingComponent: AnalysisLoading,
    delay: 120,
    timeout: 30000,
  });

const AssociationRules = createAsyncAnalysisPanel(() =>
  import("@/components/admin/analysis/AssociationRules.vue"),
);
const UserSegmentation = createAsyncAnalysisPanel(() =>
  import("@/components/admin/analysis/UserSegmentation.vue"),
);
const AnomalyDetection = createAsyncAnalysisPanel(() =>
  import("@/components/admin/analysis/AnomalyDetection.vue"),
);
const ComparisonAnalysis = createAsyncAnalysisPanel(() =>
  import("@/components/admin/analysis/ComparisonAnalysis.vue"),
);

const activeTab = ref("association");
</script>

<style scoped>
.advanced-analysis-container {
  padding: 20px;
}
.page-header {
  margin-bottom: 20px;
}
.page-title {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 8px;
}
.page-desc {
  font-size: 14px;
  color: #909399;
}
.analysis-card {
  min-height: 600px;
}
.analysis-loading {
  min-height: 520px;
  padding: 16px;
}
</style>
