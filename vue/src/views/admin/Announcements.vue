<template>
  <div class="announcements-container">
    <div class="page-header">
      <h1 class="page-title">系统公告管理</h1>
      <div class="header-actions">
        <el-button type="primary" @click="openCreate">
          <el-icon><Plus /></el-icon>
          新增公告
        </el-button>
      </div>
    </div>

    <el-card class="search-card">
      <el-form :model="searchForm" inline>
        <el-form-item label="关键词">
          <el-input
            v-model="searchForm.keyword"
            placeholder="标题或内容搜索"
            clearable
            style="width: 260px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card>
      <template #header>
        <span>公告列表</span>
      </template>
      <el-table v-loading="loading" :data="rows" style="width: 100%">
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column prop="title" label="标题" min-width="200" />
        <el-table-column
          prop="content"
          label="内容"
          min-width="360"
          show-overflow-tooltip
        />
        <el-table-column label="发布时间" width="180">
          <template #default="scope">
            {{ formatTime(scope.row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="openEdit(scope.row)"
              >编辑</el-button
            >
            <el-button
              size="small"
              type="danger"
              @click="handleDelete(scope.row)"
              >删除</el-button
            >
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <el-form
        ref="dialogFormRef"
        :model="dialogForm"
        :rules="dialogRules"
        label-width="80px"
      >
        <el-form-item label="标题" prop="title">
          <el-input v-model="dialogForm.title" placeholder="请输入公告标题" />
        </el-form-item>
        <el-form-item label="内容" prop="content">
          <el-input
            v-model="dialogForm.content"
            type="textarea"
            :rows="6"
            placeholder="请输入公告内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitForm">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import dayjs from "dayjs";
import { notificationApi } from "@/api/notification";

const loading = ref(false);
const rows = ref([]);
const searchForm = reactive({
  keyword: "",
});

const dialogVisible = ref(false);
const dialogFormRef = ref();
const dialogForm = reactive({
  id: null,
  title: "",
  content: "",
});

const dialogRules = {
  title: [{ required: true, message: "请输入公告标题", trigger: "blur" }],
  content: [{ required: true, message: "请输入公告内容", trigger: "blur" }],
};

const dialogTitle = computed(() =>
  dialogForm.id ? "编辑公告" : "新增公告",
);

const formatTime = (time) => {
  if (!time) return "-";
  return dayjs(time).format("YYYY-MM-DD HH:mm");
};

const loadAnnouncements = async () => {
  loading.value = true;
  try {
    const res = await notificationApi.admin.listAnnouncements({
      keyword: searchForm.keyword || undefined,
    });
    rows.value = res?.data?.data || [];
  } catch (e) {
    rows.value = [];
  } finally {
    loading.value = false;
  }
};

const handleSearch = () => {
  loadAnnouncements();
};

const handleReset = () => {
  searchForm.keyword = "";
  loadAnnouncements();
};

const openCreate = () => {
  dialogForm.id = null;
  dialogForm.title = "";
  dialogForm.content = "";
  dialogVisible.value = true;
};

const openEdit = (row) => {
  dialogForm.id = row.id;
  dialogForm.title = row.title || "";
  dialogForm.content = row.content || "";
  dialogVisible.value = true;
};

const submitForm = async () => {
  if (!dialogFormRef.value) return;
  await dialogFormRef.value.validate();
  try {
    if (dialogForm.id) {
      await notificationApi.admin.updateAnnouncement(dialogForm.id, {
        title: dialogForm.title,
        content: dialogForm.content,
      });
      ElMessage.success("公告已更新");
    } else {
      await notificationApi.createAnnouncement({
        title: dialogForm.title,
        content: dialogForm.content,
      });
      ElMessage.success("公告已发布");
    }
    dialogVisible.value = false;
    loadAnnouncements();
  } catch (e) {}
};

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm("确定要删除该公告吗？", "提示", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });
    await notificationApi.admin.deleteAnnouncement(row.id);
    ElMessage.success("公告已删除");
    loadAnnouncements();
  } catch (e) {}
};

onMounted(() => {
  loadAnnouncements();
});
</script>

<style scoped>
.announcements-container {
  width: 100%;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  font-size: 24px;
  color: #333;
  margin: 0;
}

.search-card {
  margin-bottom: 20px;
}
</style>
