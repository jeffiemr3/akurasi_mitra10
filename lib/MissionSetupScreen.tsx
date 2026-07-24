import React, { useState } from 'react';
import { ArrowLeft, Check, Plus, FolderPlus } from 'lucide-react';
import { CategoryAssignment, AppUser } from '../types';

interface MissionSetupScreenProps {
  categories: CategoryAssignment[];
  availableUsers: AppUser[];
  onBack: () => void;
  onUpdateAssignments: (updatedCategories: CategoryAssignment[]) => void;
}

export const MissionSetupScreen: React.FC<MissionSetupScreenProps> = ({
  categories,
  availableUsers,
  onBack,
  onUpdateAssignments,
}) => {
  const [assignments, setAssignments] = useState<CategoryAssignment[]>(categories);
  const [savedSuccess, setSavedSuccess] = useState(false);
  const [newCatName, setNewCatName] = useState('');
  const [showAddCatModal, setShowAddCatModal] = useState(false);

  const handleUserChange = (catId: string, username: string) => {
    setAssignments((prev) =>
      prev.map((a) =>
        a.id === catId
          ? { ...a, assignedUsername: username === 'none' ? null : username }
          : a
      )
    );
  };

  const handleSave = () => {
    onUpdateAssignments(assignments);
    setSavedSuccess(true);
    setTimeout(() => setSavedSuccess(false), 3000);
  };

  const handleAddCategory = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCatName.trim()) return;

    const newCat: CategoryAssignment = {
      id: `c-${Date.now()}`,
      categoryName: newCatName.trim(),
      assignedUsername: null,
      status: 'available',
      itemCount: 0,
    };

    setAssignments((prev) => [...prev, newCat]);
    setNewCatName('');
    setShowAddCatModal(false);
  };

  return (
    <div className="min-h-screen bg-[#DCE7F7] flex flex-col p-4 sm:p-6">
      <div className="w-full max-w-[640px] mx-auto flex flex-col flex-1">
        {/* Header Bar */}
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-3">
            <button
              id="btn-mission-setup-back"
              onClick={onBack}
              className="w-8 h-8 rounded-full bg-white border border-[#DDE4F0] flex items-center justify-center text-[#172554] hover:bg-gray-50"
            >
              <ArrowLeft size={16} />
            </button>
            <span className="text-[12px] font-bold tracking-wider text-[#5B688A] uppercase">
              ATUR MISI
            </span>
          </div>

          <button
            id="btn-add-cat-modal"
            onClick={() => setShowAddCatModal(true)}
            className="inline-flex items-center gap-1 px-3 py-1.5 bg-white border border-[#DDE4F0] rounded-xl text-[12px] font-semibold text-[#16225C] hover:bg-gray-50 shadow-xs"
          >
            <FolderPlus size={14} /> + Kategori
          </button>
        </div>

        {/* Card */}
        <div className="bg-white rounded-[28px] p-5 sm:p-7 flex-1 flex flex-col shadow-sm">
          <div>
            <h1 className="text-[20px] font-bold text-[#172554]">Atur misi</h1>
            <p className="text-[12px] text-[#5B688A] mt-0.5">
              Tugaskan tiap kategori ke satu akun auditor
            </p>
          </div>

          {/* List of Category Assignments */}
          <div className="mt-5 flex-1 space-y-2.5 overflow-y-auto max-h-[420px] pr-1">
            {assignments.map((item) => (
              <div
                key={item.id}
                className="p-3.5 bg-[#FAF9F5] border border-[#DDE4F0] rounded-2xl flex items-center justify-between gap-3"
              >
                <div>
                  <span className="text-[13.5px] font-medium text-[#172554] block">
                    {item.categoryName}
                  </span>
                  <span className="text-[11px] text-[#5B688A]">
                    {item.itemCount} items audit
                  </span>
                </div>

                <select
                  id={`select-cat-${item.id}`}
                  value={item.assignedUsername || 'none'}
                  onChange={(e) => handleUserChange(item.id, e.target.value)}
                  className="bg-white border border-[#DDE4F0] rounded-xl px-3 py-1.5 text-[12.5px] font-semibold text-[#16225C] focus:outline-none focus:border-[#16225C] shadow-xs cursor-pointer"
                >
                  <option value="none">-- Pilih user --</option>
                  {availableUsers.map((u) => (
                    <option key={u.id} value={u.username}>
                      {u.name} ({u.username})
                    </option>
                  ))}
                </select>
              </div>
            ))}
          </div>

          {savedSuccess && (
            <div className="mt-4 p-3 bg-[#E1F5EE] border border-[#0F6E56]/20 text-[#0F6E56] rounded-xl text-[13px] font-medium flex items-center gap-2">
              <Check size={16} /> Penugasan misi berhasil disimpan!
            </div>
          )}

          <div className="mt-6 pt-3 border-t border-[#DDE4F0]">
            <button
              id="btn-save-assignments"
              onClick={handleSave}
              className="w-full bg-[#16225C] hover:bg-[#1F2E75] text-white py-3.5 rounded-xl text-[14px] font-semibold transition-colors shadow-sm"
            >
              Simpan penugasan
            </button>
          </div>
        </div>
      </div>

      {/* Add Category Modal */}
      {showAddCatModal && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 max-w-[360px] w-full shadow-xl">
            <h3 className="text-[16px] font-bold text-[#172554]">Tambah Kategori Baru</h3>
            <form onSubmit={handleAddCategory} className="mt-4">
              <input
                type="text"
                placeholder="Nama kategori (mis: Plumbing, Electronics)"
                value={newCatName}
                onChange={(e) => setNewCatName(e.target.value)}
                className="w-full px-3.5 py-2.5 border border-[#DDE4F0] rounded-xl text-[13.5px] focus:outline-none focus:border-[#16225C]"
                autoFocus
              />
              <div className="flex gap-2.5 mt-5">
                <button
                  type="button"
                  onClick={() => setShowAddCatModal(false)}
                  className="flex-1 py-2.5 border border-[#DDE4F0] rounded-xl text-[13px] font-medium text-[#172554]"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  className="flex-1 py-2.5 bg-[#16225C] text-white rounded-xl text-[13px] font-medium"
                >
                  Tambah
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
