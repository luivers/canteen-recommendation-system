<template>
  <div class="admin-canteens-container">
    <div class="page-header">
      <h2 class="page-title">食堂管理</h2>
      <el-button type="primary" @click="showCreateDialog">
        <el-icon><Plus /></el-icon>
        新增食堂
      </el-button>
    </div>

    <!-- 搜索栏 -->
    <el-card class="filter-card" shadow="never">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索食堂名称"
            clearable
            @clear="handleSearch"
            @keyup.enter="handleSearch"
          >
            <template #append>
              <el-button @click="handleSearch">
                <el-icon><Search /></el-icon>
              </el-button>
            </template>
          </el-input>
        </el-col>
      </el-row>
    </el-card>

    <!-- 食堂列表 -->
    <el-card class="table-card" shadow="never">
      <el-table
        v-loading="loading"
        :data="filteredCanteens"
        style="width: 100%"
        stripe
      >
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="食堂名称" width="180" />
        <el-table-column prop="location" label="位置" width="200" />
        <el-table-column prop="floorCount" label="楼层数" width="100" align="center" />
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column prop="createTime" label="创建时间" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="scope">
            <el-button
              type="primary"
              link
              size="small"
              @click="showEditDialog(scope.row)"
            >
              编辑
            </el-button>
            <el-button
              type="danger"
              link
              size="small"
              @click="handleDelete(scope.row)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑食堂' : '新增食堂'"
      width="500px"
      @close="resetForm"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="食堂名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入食堂名称" />
        </el-form-item>
        <el-form-item label="位置" prop="location">
          <el-input v-model="form.location" placeholder="请输入食堂位置" />
        </el-form-item>
        <el-form-item label="楼层数" prop="floorCount">
          <el-input-number v-model="form.floorCount" :min="1" :max="10" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            rows="3"
            placeholder="请输入食堂描述"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="submitting" @click="handleSubmit">
            确定
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { Plus, Search } from "@element-plus/icons-vue";
import canteenApi from "@/api/canteen";

// 状态
const loading = ref(false);
const canteens = ref([]);
const searchKeyword = ref("");
const dialogVisible = ref(false);
const submitting = ref(false);
const isEdit = ref(false);
const formRef = ref(null);

// 表单数据
const form = ref({
  id: null,
  name: "",
  location: "",
  floorCount: 1,
  description: "",
});

// 验证规则
const rules = {
  name: [{ required: true, message: "请输入食堂名称", trigger: "blur" }],
  location: [{ required: true, message: "请输入食堂位置", trigger: "blur" }],
  floorCount: [{ required: true, message: "请输入楼层数", trigger: "change" }],
};

// 过滤后的数据
const filteredCanteens = computed(() => {
  if (!searchKeyword.value) return canteens.value;
  const keyword = searchKeyword.value.toLowerCase();
  return canteens.value.filter(
    (c) =>
      c.name.toLowerCase().includes(keyword) ||
      (c.location && c.location.toLowerCase().includes(keyword))
  );
});

// 格式化日期
const formatDate = (dateStr) => {
  if (!dateStr) return "-";
  return new Date(dateStr).toLocaleString();
};

// 获取所有食堂
const fetchCanteens = async () => {
  loading.value = true;
  try {
    const res = await canteenApi.getAll();
    canteens.value = res.data;
  } catch (error) {
    console.error("Failed to fetch canteens:", error);
    ElMessage.error("获取食堂列表失败");
  } finally {
    loading.value = false;
  }
};

// 搜索
const handleSearch = () => {
  // 实际上由computed属性处理，这里只是为了触发更新（如果需要后端搜索可以在这里调用API）
};

// 显示新增对话框
const showCreateDialog = () => {
  isEdit.value = false;
  form.value = {
    id: null,
    name: "",
    location: "",
    floorCount: 1,
    description: "",
  };
  dialogVisible.value = true;
};

// 显示编辑对话框
const showEditDialog = (row) => {
  isEdit.value = true;
  form.value = { ...row };
  dialogVisible.value = true;
};

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return;
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true;
      try {
        if (isEdit.value) {
          await canteenApi.update(form.value.id, form.value);
          ElMessage.success("更新成功");
        } else {
          await canteenApi.create(form.value);
          ElMessage.success("创建成功");
        }
        dialogVisible.value = false;
        fetchCanteens();
      } catch (error) {
        console.error("Submit failed:", error);
        ElMessage.error(error.response?.data?.message || (isEdit.value ? "更新失败" : "创建失败"));
      } finally {
        submitting.value = false;
      }
    }
  });
};

// 删除食堂
const handleDelete = (row) => {
  ElMessageBox.confirm(
    `确定要删除食堂 "${row.name}" 吗？此操作不可恢复。`,
    "警告",
    {
      confirmButtonText: "确定删除",
      cancelButtonText: "取消",
      type: "warning",
    }
  )
    .then(async () => {
      try {
        await canteenApi.delete(row.id);
        ElMessage.success("删除成功");
        fetchCanteens();
      } catch (error) {
        console.error("Delete failed:", error);
        // 后端会返回具体的错误信息（如包含窗口或菜品）
        ElMessage.error(error.response?.data?.message || "删除失败");
      }
    })
    .catch(() => {
      // 取消删除
    });
};

// 重置表单
const resetForm = () => {
  if (formRef.value) {
    formRef.value.resetFields();
  }
};

// 初始化
onMounted(() => {
  fetchCanteens();
});
</script>

<style scoped>
.admin-canteens-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  margin: 0;
  font-size: 24px;
  color: #303133;
}

.filter-card {
  margin-bottom: 20px;
}

.table-card {
  margin-bottom: 20px;
}
</style>
