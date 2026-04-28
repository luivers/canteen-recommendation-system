<template>
  <div class="page">
    <el-card class="filter-card">
      <template #header>
        <div class="card-header">
          <span>奖品管理</span>
          <div class="actions">
            <el-button @click="openCategoryManager">分类管理</el-button>
            <el-button type="primary" @click="openCreate">新增奖品</el-button>
          </div>
        </div>
      </template>

      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="分类">
          <el-select
            v-model="filters.categoryId"
            clearable
            style="width: 160px"
            @change="reload"
          >
            <el-option
              v-for="c in categories"
              :key="c.id"
              :label="c.name"
              :value="c.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="filters.status"
            clearable
            style="width: 160px"
            @change="reload"
          >
            <el-option label="可用" value="AVAILABLE" />
            <el-option label="缺货" value="OUT_OF_STOCK" />
            <el-option label="下架" value="DISCONTINUED" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input
            v-model="filters.keyword"
            placeholder="名称搜索"
            style="width: 220px"
            @keyup.enter="reload"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="reload">查询</el-button>
          <el-button @click="resetFilters">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card>
      <el-table v-loading="loading" :data="rows" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="名称" min-width="160" />
        <el-table-column label="分类" width="120">
          <template #default="scope">
            {{ scope.row.category?.name || "-" }}
          </template>
        </el-table-column>
        <el-table-column label="面值" width="100">
          <template #default="scope">
            <span
              v-if="scope.row.type === 'VOUCHER' && scope.row.faceValue != null"
              >¥{{ formatMoney(scope.row.faceValue) }}</span
            >
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="pointsRequired" label="积分" width="90" />
        <el-table-column prop="stock" label="库存" width="80" />
        <el-table-column label="可兑" width="80">
          <template #default="scope">
            <el-tag
              :type="scope.row.exchangeEnabled === false ? 'info' : 'success'"
            >
              {{ scope.row.exchangeEnabled === false ? "否" : "是" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="有效期" min-width="190">
          <template #default="scope">
            <span v-if="scope.row.validTo"
              >{{ formatTime(scope.row.validFrom) }} ~
              {{ formatTime(scope.row.validTo) }}</span
            >
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="openEdit(scope.row)"
              >编辑</el-button
            >
            <el-button
              size="small"
              type="danger"
              @click="removeVoucher(scope.row)"
              >删除</el-button
            >
          </template>
        </el-table-column>
      </el-table>

      <div v-if="pagination.total > 0" class="pagination">
        <el-pagination
          v-model:current-page="pagination.page"
          background
          layout="prev, pager, next"
          :total="pagination.total"
          :page-size="pagination.size"
          @current-change="loadData"
        />
      </div>
    </el-card>

    <el-dialog
      v-model="voucherDialogVisible"
      :title="dialogTitle"
      width="620px"
    >
      <el-form :model="voucherForm" label-width="110px">
        <el-form-item label="名称">
          <el-input v-model="voucherForm.name" />
        </el-form-item>
        <el-form-item label="分类">
          <el-select
            v-model="voucherForm.categoryId"
            clearable
            style="width: 220px"
            @change="handleCategoryChange"
          >
            <el-option
              v-for="c in categories"
              :key="c.id"
              :label="c.name"
              :value="c.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="voucherForm.type === 'VOUCHER'" label="面值">
          <el-input-number
            v-model="voucherForm.faceValue"
            :min="0"
            :precision="2"
            :step="1"
          />
        </el-form-item>
        <el-form-item v-if="voucherForm.type === 'VOUCHER'" label="最低消费">
          <el-input-number
            v-model="voucherForm.minOrderAmount"
            :min="0"
            :precision="2"
            :step="1"
          />
        </el-form-item>
        <el-form-item label="所需积分">
          <el-input-number v-model="voucherForm.pointsRequired" :min="1" />
        </el-form-item>
        <el-form-item label="库存">
          <el-input-number v-model="voucherForm.stock" :min="0" />
        </el-form-item>
        <el-form-item label="每日限额">
          <el-input-number v-model="voucherForm.dailyLimit" :min="0" />
        </el-form-item>
        <el-form-item label="单用户限额">
          <el-input-number v-model="voucherForm.perUserLimit" :min="0" />
        </el-form-item>
        <el-form-item label="可兑换">
          <el-switch v-model="voucherForm.exchangeEnabled" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="voucherForm.status" style="width: 220px">
            <el-option label="可用" value="AVAILABLE" />
            <el-option label="缺货" value="OUT_OF_STOCK" />
            <el-option label="下架" value="DISCONTINUED" />
          </el-select>
        </el-form-item>
        <el-form-item label="有效期">
          <el-date-picker
            v-model="voucherForm.validRange"
            type="datetimerange"
            value-format="YYYY-MM-DDTHH:mm:ss"
            start-placeholder="开始"
            end-placeholder="结束"
          />
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="voucherForm.description"
            type="textarea"
            :rows="2"
          />
        </el-form-item>
        <el-form-item label="使用条件">
          <el-input
            v-model="voucherForm.attributes"
            type="textarea"
            :rows="3"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="voucherDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="saveVoucher"
          >保存</el-button
        >
      </template>
    </el-dialog>

    <el-dialog v-model="categoryDialogVisible" title="分类管理" width="560px">
      <div class="category-actions">
        <el-button type="primary" @click="openCategoryCreate"
          >新增分类</el-button
        >
      </div>
      <el-table :data="categories" size="small" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="名称" min-width="160" />
        <el-table-column prop="sortOrder" label="排序" width="90" />
        <el-table-column prop="status" label="状态" width="110" />
        <el-table-column label="操作" width="160">
          <template #default="scope">
            <el-button size="small" @click="openCategoryEdit(scope.row)"
              >编辑</el-button
            >
            <el-button
              size="small"
              type="danger"
              @click="removeCategory(scope.row)"
              >删除</el-button
            >
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <el-dialog
      v-model="categoryEditVisible"
      :title="categoryEditTitle"
      width="420px"
    >
      <el-form :model="categoryForm" label-width="90px">
        <el-form-item label="名称">
          <el-input v-model="categoryForm.name" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="categoryForm.sortOrder" :min="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="categoryForm.status" style="width: 180px">
            <el-option label="启用" value="ENABLED" />
            <el-option label="禁用" value="DISABLED" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="categoryEditVisible = false">取消</el-button>
        <el-button type="primary" @click="saveCategory">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref, computed } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import dayjs from "dayjs";
import { rewardsApi } from "@/api/rewards";

const categories = ref([]);
const rows = ref([]);
const loading = ref(false);
const saving = ref(false);

const filters = reactive({
  categoryId: null,
  status: "",
  keyword: "",
});

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0,
});

const voucherDialogVisible = ref(false);
const dialogMode = ref("create");
const dialogTitle = computed(() =>
  dialogMode.value === "create" ? "新增奖品" : "编辑奖品",
);

const voucherForm = reactive({
  id: null,
  name: "",
  description: "",
  type: "VOUCHER",
  categoryId: null,
  faceValue: null,
  minOrderAmount: null,
  pointsRequired: 1,
  stock: 0,
  dailyLimit: 0,
  perUserLimit: 0,
  exchangeEnabled: true,
  status: "AVAILABLE",
  validRange: [],
  attributes: "",
});

const categoryDialogVisible = ref(false);
const categoryEditVisible = ref(false);
const categoryEditMode = ref("create");
const categoryEditTitle = computed(() =>
  categoryEditMode.value === "create" ? "新增分类" : "编辑分类",
);
const categoryForm = reactive({
  id: null,
  name: "",
  sortOrder: 0,
  status: "ENABLED",
});

const handleCategoryChange = (val) => {
  const cat = categories.value.find((c) => c.id === val);
  if (cat && cat.name.includes("代金券")) {
    voucherForm.type = "VOUCHER";
  } else {
    voucherForm.type = "OTHER";
  }
};

const formatTime = (time) => {
  if (!time) return "-";
  return dayjs(time).format("YYYY-MM-DD HH:mm");
};

const formatMoney = (v) => {
  const n = Number(v);
  if (Number.isNaN(n)) return v;
  return n.toFixed(2);
};

const loadCategories = async () => {
  try {
    const res = await rewardsApi.admin.listCategories();
    categories.value = Array.isArray(res?.data?.data) ? res.data.data : [];
  } catch (e) {
    categories.value = [];
  }
};

const loadData = async () => {
  loading.value = true;
  try {
    const res = await rewardsApi.admin.pageVouchers({
      page: pagination.page - 1,
      size: pagination.size,
      categoryId: filters.categoryId || undefined,
      keyword: filters.keyword || undefined,
      status: filters.status || undefined,
    });
    const data = res?.data?.data || {};
    rows.value = data.content || [];
    pagination.total = data.total || 0;
  } catch (e) {
    rows.value = [];
    pagination.total = 0;
    ElMessage.error("加载奖品列表失败");
  } finally {
    loading.value = false;
  }
};

const reload = () => {
  pagination.page = 1;
  loadData();
};

const resetFilters = () => {
  filters.categoryId = null;
  filters.status = "";
  filters.keyword = "";
  reload();
};

const openCreate = () => {
  dialogMode.value = "create";
  Object.assign(voucherForm, {
    id: null,
    name: "",
    description: "",
    type: "VOUCHER",
    categoryId: null,
    faceValue: null,
    minOrderAmount: null,
    pointsRequired: 1,
    stock: 0,
    dailyLimit: 0,
    perUserLimit: 0,
    exchangeEnabled: true,
    status: "AVAILABLE",
    validRange: [],
    attributes: "",
  });
  voucherDialogVisible.value = true;
};

const openEdit = (row) => {
  dialogMode.value = "edit";
  Object.assign(voucherForm, {
    id: row.id,
    name: row.name || "",
    description: row.description || "",
    type: row.type || "VOUCHER",
    categoryId: row.category?.id || null,
    faceValue: row.faceValue ?? null,
    minOrderAmount: row.minOrderAmount ?? null,
    pointsRequired: row.pointsRequired ?? 1,
    stock: row.stock ?? 0,
    dailyLimit: row.dailyLimit ?? 0,
    perUserLimit: row.perUserLimit ?? 0,
    exchangeEnabled: row.exchangeEnabled !== false,
    status: row.status || "AVAILABLE",
    validRange:
      row.validFrom && row.validTo ? [row.validFrom, row.validTo] : [],
    attributes: row.attributes || "",
  });
  voucherDialogVisible.value = true;
};

const saveVoucher = async () => {
  saving.value = true;
  try {
    const isVoucher = voucherForm.type === "VOUCHER";
    const payload = {
      name: voucherForm.name,
      description: voucherForm.description,
      type: voucherForm.type,
      categoryId: voucherForm.categoryId,
      faceValue: isVoucher ? voucherForm.faceValue : null,
      minOrderAmount: isVoucher ? voucherForm.minOrderAmount : null,
      pointsRequired: voucherForm.pointsRequired,
      stock: voucherForm.stock,
      dailyLimit: voucherForm.dailyLimit,
      perUserLimit: voucherForm.perUserLimit,
      exchangeEnabled: voucherForm.exchangeEnabled,
      status: voucherForm.status,
      validFrom:
        Array.isArray(voucherForm.validRange) &&
        voucherForm.validRange.length === 2
          ? voucherForm.validRange[0]
          : null,
      validTo:
        Array.isArray(voucherForm.validRange) &&
        voucherForm.validRange.length === 2
          ? voucherForm.validRange[1]
          : null,
      attributes: voucherForm.attributes,
    };
    if (dialogMode.value === "create") {
      await rewardsApi.admin.createVoucher(payload);
      ElMessage.success("创建成功");
    } else {
      await rewardsApi.admin.updateVoucher(voucherForm.id, payload);
      ElMessage.success("更新成功");
    }
    voucherDialogVisible.value = false;
    await loadCategories();
    await loadData();
  } catch (e) {
    const msg = e?.response?.data?.message || "保存失败";
    ElMessage.error(msg);
  } finally {
    saving.value = false;
  }
};

const removeVoucher = async (row) => {
  try {
    await ElMessageBox.confirm("确定删除该奖品吗？", "提示", {
      type: "warning",
    });
    await rewardsApi.admin.deleteVoucher(row.id);
    ElMessage.success("删除成功");
    await loadData();
  } catch (e) {}
};

const openCategoryManager = async () => {
  await loadCategories();
  categoryDialogVisible.value = true;
};

const openCategoryCreate = () => {
  categoryEditMode.value = "create";
  Object.assign(categoryForm, {
    id: null,
    name: "",
    sortOrder: 0,
    status: "ENABLED",
  });
  categoryEditVisible.value = true;
};

const openCategoryEdit = (row) => {
  categoryEditMode.value = "edit";
  Object.assign(categoryForm, {
    id: row.id,
    name: row.name,
    sortOrder: row.sortOrder ?? 0,
    status: row.status || "ENABLED",
  });
  categoryEditVisible.value = true;
};

const saveCategory = async () => {
  try {
    const payload = {
      name: categoryForm.name,
      sortOrder: categoryForm.sortOrder,
      status: categoryForm.status,
    };
    if (categoryEditMode.value === "create") {
      await rewardsApi.admin.createCategory(payload);
      ElMessage.success("创建分类成功");
    } else {
      await rewardsApi.admin.updateCategory(categoryForm.id, payload);
      ElMessage.success("更新分类成功");
    }
    categoryEditVisible.value = false;
    await loadCategories();
    await loadData();
  } catch (e) {
    const msg = e?.response?.data?.message || "保存分类失败";
    ElMessage.error(msg);
  }
};

const removeCategory = async (row) => {
  try {
    await ElMessageBox.confirm("确定删除该分类吗？", "提示", {
      type: "warning",
    });
    await rewardsApi.admin.deleteCategory(row.id);
    ElMessage.success("删除成功");
    await loadCategories();
    await loadData();
  } catch (e) {}
};

onMounted(async () => {
  await loadCategories();
  await loadData();
});
</script>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.filter-card {
  margin-bottom: 0;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.actions {
  display: flex;
  gap: 10px;
}

.pagination {
  margin-top: 10px;
  display: flex;
  justify-content: flex-end;
}

.category-actions {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 10px;
}
</style>
